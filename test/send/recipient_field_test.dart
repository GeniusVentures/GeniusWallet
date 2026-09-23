// RecipientField in isolation: paste, the self-send warning, the contract
// warning and (a later task) scan gating -- send_screen_test.dart covers the
// field wired into the full form.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/services/transaction_storage_service.dart';
import 'package:genius_wallet/send/recipient_field.dart';
import 'package:genius_wallet/send/send_cubit.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

const _walletAddress = '0x1111111111111111111111111111111111111111';
const _otherAddress = '0x2222222222222222222222222222222222222222';
const _thirdAddress = '0x3333333333333333333333333333333333333333';

const _amoy = Network(
  name: 'Polygon Amoy',
  symbol: 'matic',
  chainId: 80002,
  rpcUrl: 'https://rpc.invalid',
);

const _maticCoin = Coin(symbol: 'matic', balance: 10);

class _NoopStorage implements TransactionStorageService {
  @override
  Future<void> addTransaction(String walletAddress, Transaction tx) async {}

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

/// Every `hasCode` call is recorded, so a test can prove the wallet's own
/// address was never queried. [gate] holds every answer back until
/// [release], so a test can change the recipient mid-flight and prove the
/// stale one is ignored.
class _FakeApi implements GeniusApi {
  final Map<String, bool> _answers = {};
  final Set<String> _throwsFor = {};
  final List<String> hasCodeCalls = [];
  Completer<void>? _gate;

  void answer(String address, {required bool hasCode}) =>
      _answers[address.toLowerCase()] = hasCode;

  void throwFor(String address) => _throwsFor.add(address.toLowerCase());

  void gate() => _gate = Completer<void>();

  void release() => _gate?.complete();

  @override
  Future<bool> hasCode({
    required String address,
    required String rpcUrl,
  }) async {
    hasCodeCalls.add(address);
    if (_gate != null) {
      await _gate!.future;
    }
    if (_throwsFor.contains(address.toLowerCase())) {
      throw Exception('rpc down');
    }
    return _answers[address.toLowerCase()] ?? false;
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

String? _clipboardText;

Future<SendCubit> _pump(
  WidgetTester tester, {
  String? errorText,
  GeniusApi? api,
  bool? canScan,
}) async {
  final cubit = SendCubit(
    api: api ?? _FakeApi(),
    walletAddress: _walletAddress,
    network: _amoy,
    transactions: TransactionsCubit(),
    storage: _NoopStorage(),
    initialCoin: _maticCoin,
  );
  addTearDown(cubit.close);

  await tester.pumpWidget(
    BlocProvider<SendCubit>.value(
      value: cubit,
      child: MaterialApp(
        theme: ThemeData(extensions: [GWColors.dark()]),
        home: Scaffold(
          body: RecipientField(errorText: errorText, canScan: canScan),
        ),
      ),
    ),
  );
  await tester.pump();
  return cubit;
}

void main() {
  setUp(() {
    _clipboardText = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.getData') {
            return <String, dynamic>{'text': _clipboardText};
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('pasting the wallet address fills the field and shows the '
      'self-send note', (tester) async {
    _clipboardText = _walletAddress;
    final cubit = await _pump(tester);

    await tester.tap(find.widgetWithText(GWButton, 'Paste'));
    await tester.pump();

    expect(cubit.state.recipient, _walletAddress);
    expect(find.textContaining('This is your own address'), findsOneWidget);
  });

  testWidgets('pasting a different address shows no self-send note', (
    tester,
  ) async {
    _clipboardText = _otherAddress;
    final cubit = await _pump(tester);

    await tester.tap(find.widgetWithText(GWButton, 'Paste'));
    await tester.pump();

    expect(cubit.state.recipient, _otherAddress);
    expect(find.textContaining('This is your own address'), findsNothing);
  });

  testWidgets(
    'a passed-in errorText shows under the field when the format check has '
    'nothing to say',
    (tester) async {
      await _pump(tester, errorText: 'Enter an amount to send.');

      expect(find.text('Enter an amount to send.'), findsOneWidget);
    },
  );

  testWidgets("the field's own format error wins over a passed-in errorText", (
    tester,
  ) async {
    final cubit = await _pump(tester, errorText: 'Enter an amount to send.');
    cubit.setRecipient('not-an-address');
    await tester.pumpAndSettle();

    expect(
      find.text('Enter a 0x address of 40 hex characters.'),
      findsOneWidget,
    );
    expect(find.text('Enter an amount to send.'), findsNothing);
  });

  testWidgets('a recipient with code on-chain shows the contract note', (
    tester,
  ) async {
    final api = _FakeApi()..answer(_otherAddress, hasCode: true);
    final cubit = await _pump(tester, api: api);

    cubit.setRecipient(_otherAddress);
    await tester.pumpAndSettle();

    expect(find.textContaining('This address is a contract'), findsOneWidget);
  });

  testWidgets('a recipient with no code shows no contract note', (
    tester,
  ) async {
    final api = _FakeApi()..answer(_otherAddress, hasCode: false);
    final cubit = await _pump(tester, api: api);

    cubit.setRecipient(_otherAddress);
    await tester.pumpAndSettle();

    expect(find.textContaining('This address is a contract'), findsNothing);
  });

  testWidgets('a thrown contract check shows no note', (tester) async {
    final api = _FakeApi()..throwFor(_otherAddress);
    final cubit = await _pump(tester, api: api);

    cubit.setRecipient(_otherAddress);
    await tester.pumpAndSettle();

    expect(find.textContaining('This address is a contract'), findsNothing);
  });

  testWidgets(
    'an answer that arrives after the recipient changed again is ignored',
    (tester) async {
      final api = _FakeApi()
        ..answer(_otherAddress, hasCode: true)
        ..gate();
      final cubit = await _pump(tester, api: api);

      cubit.setRecipient(_otherAddress);
      await tester.pump();
      // Edited again before the first check landed -- its answer must never
      // apply to what is now typed.
      cubit.setRecipient(_thirdAddress);
      api.release();
      await tester.pumpAndSettle();

      expect(find.textContaining('This address is a contract'), findsNothing);
    },
  );

  testWidgets("the wallet's own address is never queried for contract code", (
    tester,
  ) async {
    final api = _FakeApi();
    final cubit = await _pump(tester, api: api);

    cubit.setRecipient(_walletAddress);
    await tester.pumpAndSettle();

    expect(api.hasCodeCalls, isEmpty);
  });

  group('addressFromScan', () {
    test('a bare address round-trips', () {
      expect(addressFromScan(_otherAddress), _otherAddress);
    });

    test('an EIP-681 payment link yields only the address', () {
      expect(
        addressFromScan('ethereum:$_otherAddress@137?value=1e18'),
        _otherAddress,
      );
    });

    test('upper-case hex still matches', () {
      const upper = '0xABCDEF0123456789ABCDEF0123456789ABCDEF01';
      expect(addressFromScan(upper), upper);
    });

    test('garbage with no address yields null', () {
      expect(addressFromScan('not a QR payload'), isNull);
    });

    test('a token payment link yields its payee, never the token contract', () {
      const token = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';
      expect(
        addressFromScan(
          'ethereum:$token@1/transfer?address=$_otherAddress&uint256=1e6',
        ),
        _otherAddress,
      );
    });

    test('a token link with no readable payee yields null', () {
      const token = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';
      expect(addressFromScan('ethereum:$token@1/transfer?uint256=1'), isNull);
      expect(
        addressFromScan('ethereum:$token/approve?address=$_otherAddress'),
        isNull,
      );
    });

    test('a longer hex run (a hash or a key) is not cut to an address', () {
      final hash = '0x${'ab' * 32}';
      expect(addressFromScan(hash), isNull);
      expect(addressFromScan('ethereum:$hash'), isNull);
    });
  });

  group('canScan gating', () {
    testWidgets('false shows no Scan button', (tester) async {
      await _pump(tester, canScan: false);

      expect(find.widgetWithText(GWButton, 'Scan'), findsNothing);
    });

    testWidgets('true shows a Scan button (never tapped: no camera in '
        'tests)', (tester) async {
      await _pump(tester, canScan: true);

      expect(find.widgetWithText(GWButton, 'Scan'), findsOneWidget);
    });
  });
}
