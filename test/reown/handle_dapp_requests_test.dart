// The session-request handler: the one place a dApp's request becomes either
// a signature or an answer saying why not.
//
// Two live bugs are pinned here.
//
//   1. The transaction map used to be cast out of `params[0]` before the
//      method was read. `personal_sign` and `eth_signTypedData` carry a
//      String there, so the cast threw, the catch-all swallowed it, and the
//      dApp received NO response at all -- it waited forever.
//   2. The rejection shipped `Errors.USER_REJECTED.toInt()`, which reads a
//      lookup key as a number and yields null. The serializer omits null
//      fields, so the rejection went out with no code in it.
//
// The rule both bugs broke is the one this file exists to hold: every request
// that reaches the handler leaves it with exactly one answer.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/navigation/router.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/reown/calldata_decoder.dart';
import 'package:genius_wallet/reown/handle_dapp_requests.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
// web3dart comes through reown wholesale and brings its own Wallet with it.
import 'package:reown_walletkit/reown_walletkit.dart' hide Wallet;

const _signMethods = [
  'personal_sign',
  'eth_signTypedData',
  'eth_signTypedData_v4',
];

/// What a `personal_sign` actually carries: a hex message and an address,
/// both Strings. Casting `[0]` to a Map here is the throw this file pins.
const _signParams = [
  '0x48656c6c6f',
  '0x0000000000000000000000000000000000000001',
];

const _base = Network(
  name: 'Base',
  symbol: 'eth',
  chainId: 8453,
  rpcUrl: 'https://base.invalid',
);

/// A chain whose coin is not ether, which is the only way a hard-coded `ETH`
/// shows up as wrong rather than accidentally right.
const _polygon = Network(
  name: 'Polygon',
  symbol: 'matic',
  chainId: 137,
  rpcUrl: 'https://polygon.invalid',
);

const _tokenContract = '0xdbF03B407c01E7cD3CBea99509d93f8DDDC8C6FB';
const _usdc = Coin(symbol: 'USDC', address: _tokenContract, decimals: '6');

const _wallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Wallet A',
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: '0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
);

/// transfer(address,uint256) of 1500000 base units -- 1.5 at six decimals.
const _transferCalldata =
    '0xa9059cbb'
    '0000000000000000000000005aaeb6053f3e94c9b9a09f33669435e7ef1beaed'
    '000000000000000000000000000000000000000000000000000000000016e360';

/// A well-formed call to a function this wallet has no ABI for.
const _unreadableCalldata =
    '0xdeadbeef'
    '0000000000000000000000005aaeb6053f3e94c9b9a09f33669435e7ef1beaed'
    '000000000000000000000000000000000000000000000000000000000016e360';

Map<String, dynamic> _tx({String? data, String value = '0x2386f26fc10000'}) =>
    <String, dynamic>{
      'from': '0x0000000000000000000000000000000000000001',
      'to': _tokenContract,
      'value': value,
      'gas': '0x5208',
      'maxFeePerGas': '0x3b9aca00',
      'maxPriorityFeePerGas': '0x3b9aca00',
      'data': ?data,
    };

// The recorded Squid route, trimmed. Its byte-level facts are asserted where
// the decoder itself is; what this file asks is whether the selected network
// ever reaches that decoder at all.
final _squidRequest =
    (jsonDecode(
              File(
                'test/reown/fixtures/squid_route_transaction_request.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>)['transactionRequest']
        as Map<String, dynamic>;

const _gnus = Coin(
  symbol: 'GNUS',
  address: '0x614577036f0a024dbc1c88ba616b394dd65d105a',
  decimals: '18',
);

Map<String, dynamic> _swapTx() => <String, dynamic>{
  'from': '0x0000000000000000000000000000000000000001',
  'to': _squidRequest['target'] as String,
  'value': '0x0',
  'gas': '0xec9c0',
  'maxFeePerGas': '0xa7d8c0',
  'maxPriorityFeePerGas': '0xf4240',
  'data': _squidRequest['data'] as String,
};

SessionRequestEvent _request(String method, dynamic params, {int id = 1}) =>
    SessionRequestEvent(
      id,
      'topic-1',
      method,
      'eip155:8453',
      params,
      TransportType.relay,
    );

/// See `account_drawer_show_test.dart` for why this is `implements` plus
/// `noSuchMethod`: a real `GeniusApi` dlopens the native framework and takes
/// the test host with it.
class _FakeGeniusApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Signs nothing and reports success, so the branch that writes the record
/// can be walked without a signer or a key.
class _SigningGeniusApi implements GeniusApi {
  @override
  Future<ApiResponse<String>> signAndSendTransaction({
    required Map<String, dynamic> tx,
    required String rpcUrl,
    required String address,
    required int sourceChainId,
  }) async => ApiResponse.success('0xabc123');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Records what the wallet answered. Sessions are deliberately empty so no
/// `SessionData` graph has to be built to ask a question about responses.
class _FakeWalletKit implements ReownWalletKit {
  final List<JsonRpcResponse> responses = <JsonRpcResponse>[];
  final Event<SessionRequestEvent> _sessionRequest =
      Event<SessionRequestEvent>();

  @override
  Event<SessionRequestEvent> get onSessionRequest => _sessionRequest;

  @override
  Map<String, SessionData> getActiveSessions() => <String, SessionData>{};

  @override
  Future<void> respondSessionRequest({
    required String topic,
    required JsonRpcResponse response,
  }) async {
    responses.add(response);
  }

  void send(SessionRequestEvent event) => _sessionRequest.broadcast(event);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Harness {
  _Harness(this.walletKit, this.cubit, this.transactions, this.dispose);

  final _FakeWalletKit walletKit;
  final WalletDetailsCubit cubit;
  final TransactionsCubit transactions;
  final void Function() dispose;

  JsonRpcResponse get answer => walletKit.responses.single;
}

/// Pumps a host carrying the app's real `navigatorKey`, which is the only
/// context the handler has to open a drawer with.
Future<_Harness> _start(
  WidgetTester tester, {
  Network? network,
  List<Coin> coins = const [],
  Wallet? wallet,
  GeniusApi? api,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(extensions: [GWColors.dark()]),
      home: const Scaffold(body: SizedBox.shrink()),
    ),
  );
  final cubit = WalletDetailsCubit(
    initialState: WalletDetailsState(
      selectedNetwork: network,
      coins: coins,
      selectedWallet: wallet,
    ),
    geniusApi: _FakeGeniusApi(),
    networkTokensProvider: NetworkTokensProvider(),
  );
  final walletKit = _FakeWalletKit();
  final transactions = TransactionsCubit();
  final dispose = handleDappRequests(
    walletKit: walletKit,
    geniusApi: api ?? _FakeGeniusApi(),
    walletDetailsCubit: cubit,
    transactionsCubit: transactions,
  );
  return _Harness(walletKit, cubit, transactions, dispose);
}

Future<void> _finish(WidgetTester tester, _Harness harness) async {
  harness.dispose();
  await harness.cubit.close();
  await tester.pumpAndSettle();
}

bool _onScreen(WidgetTester tester, String value) => tester
    .widgetList<Text>(find.byType(Text))
    .any((t) => (t.data ?? '').contains(value));

void main() {
  group('the method is read before anything is cast', () {
    test('a String first param classifies for every signing method', () {
      for (final method in _signMethods) {
        expect(
          () => classifyDappRequest(method, _signParams),
          returnsNormally,
          reason: '$method must not throw on its own parameter shape',
        );
        expect(
          classifyDappRequest(method, _signParams),
          DappRequestKind.unreadableSignature,
        );
      }
    });

    test('eth_sendTransaction still classifies from its Map', () {
      expect(
        classifyDappRequest('eth_sendTransaction', [_tx()]),
        DappRequestKind.transaction,
      );
    });

    test('no parameter shape at all makes it throw', () {
      for (final params in <dynamic>[
        null,
        <dynamic>[],
        'a bare string',
        <dynamic>['not a map'],
        <String, dynamic>{'not': 'a list'},
        [42],
      ]) {
        expect(
          () => classifyDappRequest('eth_sendTransaction', params),
          returnsNormally,
          reason: 'params $params must not throw',
        );
        expect(
          classifyDappRequest('eth_sendTransaction', params),
          DappRequestKind.unsupportedMethod,
        );
      }
    });

    test('an unhandled method is named as such, not guessed at', () {
      expect(
        classifyDappRequest('eth_chainId', [_tx()]),
        DappRequestKind.unsupportedMethod,
      );
    });

    test('the transaction handed on is the SAME map, not a copy', () {
      // The signer re-reads this instance. A copy here would be a second
      // chance for the bytes to drift from what the drawer showed.
      final tx = _tx();
      expect(identical(transactionParam([tx]), tx), isTrue);
    });
  });

  group('a rejection carries a real code', () {
    test('it is 5000', () {
      // The literal, not the expression under test dressed up as an
      // expectation: round-tripping `getSdkError` here would pass even if the
      // key were wrong.
      expect(userRejectedError().code, 5000);
      expect(userRejectedError().message, isNotEmpty);
    });

    test('and the call it replaces really does yield null', () {
      // Why the bug was invisible: this compiles, runs, and produces a
      // response with no code field at all.
      expect(int.tryParse(Errors.USER_REJECTED), isNull);
    });
  });

  group('every request is answered', () {
    testWidgets('a signing method says it cannot be read, and is refused', (
      tester,
    ) async {
      final harness = await _start(tester, network: _base);
      harness.walletKit.send(_request('personal_sign', _signParams));
      await tester.pumpAndSettle();

      expect(_onScreen(tester, 'personal_sign'), isTrue);
      expect(_onScreen(tester, 'cannot'), isTrue);

      await tester.tap(find.text('Reject'));
      await tester.pumpAndSettle();

      expect(harness.answer.error?.code, 5000);
      expect(harness.answer.result, isNull);
      await _finish(tester, harness);
    });

    testWidgets('approving a signing method still signs nothing', (
      tester,
    ) async {
      // There is no typed-data renderer behind this screen, so an approval
      // would be a signature over something nobody read.
      final harness = await _start(tester, network: _base);
      harness.walletKit.send(_request('eth_signTypedData_v4', _signParams));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Approve'));
      await tester.pumpAndSettle();

      expect(harness.answer.error?.code, 5000);
      expect(harness.answer.result, isNull);
      await _finish(tester, harness);
    });

    testWidgets('eth_signTypedData is answered too', (tester) async {
      final harness = await _start(tester, network: _base);
      harness.walletKit.send(_request('eth_signTypedData', _signParams));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reject'));
      await tester.pumpAndSettle();

      expect(harness.walletKit.responses, hasLength(1));
      await _finish(tester, harness);
    });

    testWidgets('a method with no handler names itself and is answered', (
      tester,
    ) async {
      final harness = await _start(tester, network: _base);
      harness.walletKit.send(_request('eth_chainId', [_tx()]));
      await tester.pumpAndSettle();

      expect(_onScreen(tester, 'eth_chainId'), isTrue);

      await tester.tap(find.text('Reject'));
      await tester.pumpAndSettle();

      expect(harness.answer.error?.code, 5000);
      await _finish(tester, harness);
    });

    testWidgets(
      'a plain send names the chain own coin, on the screen and in the record',
      (tester) async {
        // The drawer and the stored receipt read the unit from two different
        // places once. On a chain whose coin is not ether they disagreed:
        // the screen said ETH while history said POL.
        final harness = await _start(tester, network: _polygon);
        harness.walletKit.send(_request('eth_sendTransaction', [_tx()]));
        await tester.pumpAndSettle();

        expect(_onScreen(tester, '0.0100000000 MATIC'), isTrue);
        expect(_onScreen(tester, 'ETH'), isFalse);

        await tester.tap(find.text('Reject'));
        await tester.pumpAndSettle();
        await _finish(tester, harness);
      },
    );

    testWidgets(
      'an unreadable transaction shows the wallet network, not the dApp chain',
      (tester) async {
        // The only place the selected network reaches the drawer. Both values
        // come from the wallet: the dApp does not get to name the chain the
        // user is told they are on.
        final harness = await _start(tester, network: _base);
        harness.walletKit.send(
          _request('eth_sendTransaction', [_tx(data: _unreadableCalldata)]),
        );
        await tester.pumpAndSettle();

        expect(_onScreen(tester, 'Unknown contract call'), isTrue);
        expect(_onScreen(tester, 'Base'), isTrue);
        expect(_onScreen(tester, '0.0100000000 eth'), isTrue);

        await tester.tap(find.text('Reject'));
        await tester.pumpAndSettle();

        expect(harness.answer.error?.code, 5000);
        await _finish(tester, harness);
      },
    );

    testWidgets('the selected chain is what makes a router a router', (
      tester,
    ) async {
      // The one link between the wallet's own network and the allow-list. Cut
      // it and every swap silently becomes an unknown contract call.
      final harness = await _start(
        tester,
        network: _base,
        coins: const [_gnus],
      );
      harness.walletKit.send(_request('eth_sendTransaction', [_swapTx()]));
      await tester.pumpAndSettle();

      expect(_onScreen(tester, 'Swapping 1 GNUS via Squid'), isTrue);
      expect(_onScreen(tester, 'cannot read'), isTrue);
      // The destination of that route is USDC, and its address is in the
      // payload. Nothing on screen may name it.
      expect(_onScreen(tester, 'USDC'), isFalse);

      await tester.tap(find.text('Reject'));
      await tester.pumpAndSettle();

      expect(harness.answer.error?.code, 5000);
      await _finish(tester, harness);
    });

    testWidgets('with no network selected the same swap cannot be read', (
      tester,
    ) async {
      final harness = await _start(tester, coins: const [_gnus]);
      harness.walletKit.send(_request('eth_sendTransaction', [_swapTx()]));
      await tester.pumpAndSettle();

      expect(_onScreen(tester, 'Unknown contract call'), isTrue);
      expect(_onScreen(tester, 'Squid'), isFalse);

      await tester.tap(find.text('Reject'));
      await tester.pumpAndSettle();

      expect(harness.answer.error?.code, 5000);
      await _finish(tester, harness);
    });

    testWidgets(
      'an approval the wallet cannot act on is a failure, not a rejection',
      (tester) async {
        // No selected network, so there is no chain to send on. This used to
        // return in silence, which is the same hang from a different door.
        final harness = await _start(tester);
        harness.walletKit.send(_request('eth_sendTransaction', [_tx()]));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Approve'));
        await tester.pumpAndSettle();

        expect(harness.answer.error?.code, -32000);
        await _finish(tester, harness);
      },
    );
  });

  group('the receipt agrees with the screen that authorised it', () {
    // No native value: a token call that ALSO moves native currency is its
    // own kind, and would answer a different question than this group asks.
    DappCallSummary summaryOf(String? data, {List<Coin> coins = const []}) =>
        summarizeTransaction(
          _tx(data: data, value: '0x0'),
          coins: coins,
        );

    test('a decoded token send is filed under its token', () {
      expect(
        receiptSymbol(
          summaryOf(_transferCalldata, coins: const [_usdc]),
          nativeSymbol: 'ETH',
        ),
        'USDC',
      );
    });

    test('a plain send keeps the unit of the chain it is on', () {
      expect(receiptSymbol(summaryOf(null), nativeSymbol: 'ETH'), 'ETH');
    });

    test('a token the wallet cannot name is filed under its contract', () {
      // Not ETH, which it demonstrably is not, and not an invented ticker.
      // The address is the only true thing there is to write down.
      expect(
        receiptSymbol(summaryOf(_transferCalldata), nativeSymbol: 'ETH'),
        _tokenContract,
      );
    });

    test('an unreadable call is filed under the chain unit it moved', () {
      expect(
        receiptSymbol(summaryOf(_unreadableCalldata), nativeSymbol: 'ETH'),
        'ETH',
      );
    });

    testWidgets('the record written after an approval carries that symbol', (
      tester,
    ) async {
      // The whole point of threading it: history used to say ETH for a token
      // it never moved, contradicting the drawer that authorised it.
      //
      // The Hive write that follows throws here -- no box is open in a widget
      // test -- and the handler swallows it, which is why the assertion is on
      // the cubit the same model was streamed to a line earlier.
      final harness = await _start(
        tester,
        network: _base,
        coins: const [_usdc],
        wallet: _wallet,
        api: _SigningGeniusApi(),
      );
      harness.walletKit.send(
        _request('eth_sendTransaction', [
          _tx(data: _transferCalldata, value: '0x0'),
        ]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Approve'));
      await tester.pumpAndSettle();

      expect(harness.answer.result, '0xabc123');
      expect(harness.transactions.state.single.coinSymbol, 'USDC');
      await _finish(tester, harness);
    });
  });
}
