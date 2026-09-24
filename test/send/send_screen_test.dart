// The tracer: form -> fee -> review -> sign -> pending -> completed, on a
// stubbed GeniusApi so no RPC, key or real Hive box is involved (real Hive
// I/O inside testWidgets hangs here, same reasoning as swap_submit_test.dart).
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_api/web3/send_service.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/coins/view/coin_card_row.dart';
import 'package:genius_wallet/components/coins/view/coins_screen.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/components/feedback/gw_warning_note.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/services/transaction_storage_service.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/reown/utilities.dart' show parseHexToBigInt;
import 'package:genius_wallet/send/recipient_field.dart';
import 'package:genius_wallet/send/send_cubit.dart';
import 'package:genius_wallet/send/send_screen.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:web3dart/web3dart.dart' show TransactionReceipt;

const _hash = '0xfeedfacefeedfacefeedfacefeedfacefeedface';
const _walletAddress = '0xSENDSENDSENDSENDSENDSENDSENDSENDSENDSEND';
const _recipient = '0x1234567890123456789012345678901234567890';

const _amoy = Network(
  name: 'Polygon Amoy',
  symbol: 'matic',
  chainId: 80002,
  rpcUrl: 'https://rpc.invalid',
);

const _maticCoin = Coin(symbol: 'matic', balance: 10);
const _usdcCoin = Coin(
  symbol: 'usdc',
  address: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
  decimals: '6',
  balance: 500,
);

/// Records every write instead of touching Hive.
class _RecordingStorage implements TransactionStorageService {
  final List<Transaction> writes = [];

  @override
  Future<void> addTransaction(String walletAddress, Transaction tx) async =>
      writes.add(tx);

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

/// Answers every send read with a fixed, positive fee and balance, and
/// settles the receipt on the first poll — no real RPC, no wait.
class _FakeApi implements GeniusApi {
  _FakeApi({
    this.receiptStatus = '0x1',
    this.feeFails = false,
    this.recipientIsContract = false,
  });

  final String receiptStatus;
  final bool feeFails;
  final bool recipientIsContract;
  Map<String, dynamic>? signedTx;

  @override
  Future<bool> hasCode({
    required String address,
    required String rpcUrl,
  }) async => recipientIsContract;

  @override
  Future<BigInt> readTokenBalance({
    required String address,
    required String contractAddress,
    required String rpcUrl,
  }) async => BigInt.parse('500000000'); // 500 USDC

  @override
  Future<BigInt> nativeBalance({
    required String address,
    required String rpcUrl,
  }) async => BigInt.parse('10000000000000000000');

  @override
  Future<SendFee> estimateSendFee({
    required String rpcUrl,
    required String sender,
    required String recipient,
    Uint8List? data,
    BigInt? value,
    int? chainId,
  }) async {
    if (feeFails) {
      throw const SendFeeUnavailable();
    }
    return SendFee(
      maxFeePerGas: BigInt.from(30000000000),
      maxPriorityFeePerGas: BigInt.from(1500000000),
      gasLimit: BigInt.from(21000),
    );
  }

  @override
  Future<ApiResponse<String>> signAndSendTransaction({
    required Map<String, dynamic> tx,
    required String rpcUrl,
    required String address,
    required int sourceChainId,
  }) async {
    signedTx = tx;
    return ApiResponse.success(_hash);
  }

  @override
  Future<TransactionReceipt?> transactionReceipt({
    required String hash,
    required String rpcUrl,
  }) async => TransactionReceipt.fromMap({
    'transactionHash': _hash,
    'transactionIndex': '0x0',
    'blockHash': _hash,
    'cumulativeGasUsed': '0x5208',
    'gasUsed': '0x5208',
    'effectiveGasPrice': '30000000000',
    'status': receiptStatus,
  });

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

const _wallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Send Wallet',
  currencySymbol: 'MATIC',
  walletType: WalletType.mnemonic,
  balance: 0,
  address: _walletAddress,
);

class _SeededCubit extends WalletDetailsCubit {
  _SeededCubit({
    required super.geniusApi,
    required super.networkTokensProvider,
  }) {
    emit(
      state.copyWith(
        selectedWallet: _wallet,
        selectedNetwork: _amoy,
        coins: const [_maticCoin, _usdcCoin],
        coinsNetwork: _amoy,
        coinsStatus: WalletStatus.successful,
        selectedWalletBalance: '10',
      ),
    );
  }

  /// Swaps the network without `selectNetwork`'s `getCoins()` refetch, which
  /// this fixture's `_FakeApi` can't answer. The previous network's coins stay
  /// on state, as they do until the real refetch lands.
  void debugSelectNetwork(Network network) =>
      emit(state.copyWith(selectedNetwork: network));

  /// Test-only: what a finished `getCoins()` for [network] leaves on state.
  void debugCoinsLoaded(Network network, List<Coin> coins) => emit(
    state.copyWith(
      coins: coins,
      coinsNetwork: network,
      coinsStatus: WalletStatus.successful,
    ),
  );
}

const _ethereum = Network(
  name: 'Ethereum',
  symbol: 'eth',
  chainId: 1,
  rpcUrl: 'https://rpc.invalid',
);

/// Shares Ethereum's `eth` chain key, so a network symbol alone can't tell
/// a mainnet coin from a Sepolia one.
const _sepolia = Network(
  name: 'Ethereum Sepolia',
  symbol: 'eth',
  chainId: 11155111,
  rpcUrl: 'https://rpc.invalid',
);

const _mainnetUsdc = Coin(
  symbol: 'usdc',
  address: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
  decimals: '6',
  networkSymbol: 'eth',
  balance: 500,
);

/// Mounts `/send` over [walletCubit] as it stands -- the tests below put it
/// mid-switch first.
Future<void> _mountOver(
  WidgetTester tester,
  _SeededCubit walletCubit, {
  String? symbol,
  String? address,
}) async {
  tester.view.physicalSize = const Size(1200, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<WalletDetailsCubit>.value(value: walletCubit),
        BlocProvider<TransactionsCubit>(create: (_) => TransactionsCubit()),
      ],
      child: MaterialApp(
        theme: ThemeData(extensions: [GWColors.dark()]),
        home: SendScreen(preselectSymbol: symbol, preselectAddress: address),
      ),
    ),
  );
  await tester.pump();
}

final _sendCubitProvider = find.byWidgetPredicate(
  (w) => w is BlocProvider<SendCubit>,
);

/// An unsignable chain: no chain id and no RPC, so `canSignOn` refuses it.
const _unsignableNetwork = Network(name: 'No RPC', symbol: 'none');

Future<void> _mount(
  WidgetTester tester,
  _FakeApi api,
  _RecordingStorage storage,
  TransactionsCubit transactionsCubit, {
  String symbol = 'matic',
  String? address,
  List<Coin>? coins,
  Size size = const Size(1200, 1800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<WalletDetailsCubit>(
          create: (_) {
            final cubit = _SeededCubit(
              geniusApi: api,
              networkTokensProvider: NetworkTokensProvider(),
            );
            if (coins != null) {
              cubit.debugCoinsLoaded(_amoy, coins);
            }
            return cubit;
          },
        ),
        BlocProvider<TransactionsCubit>.value(value: transactionsCubit),
      ],
      child: MaterialApp(
        theme: ThemeData(extensions: [GWColors.dark()]),
        home: SendScreen(
          preselectSymbol: symbol,
          preselectAddress: address,
          preselectChainId: 80002,
          storage: storage,
        ),
      ),
    ),
  );
  await tester.pump();
}

/// Mounts `/send` the way the app does: inside a `ShellRoute`, whose nested
/// navigator sits under the root one the review drawer opens on.
Future<GoRouter> _mountInShell(
  WidgetTester tester,
  _FakeApi api,
  _RecordingStorage storage,
  TransactionsCubit transactionsCubit,
) async {
  tester.view.physicalSize = const Size(1200, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        builder: (context, state, child) => Scaffold(body: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, _) => const Text('dashboard'),
          ),
          GoRoute(
            path: '/send',
            builder: (_, _) => SendScreen(
              preselectSymbol: 'matic',
              preselectChainId: 80002,
              storage: storage,
            ),
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<WalletDetailsCubit>(
          create: (_) => _SeededCubit(
            geniusApi: api,
            networkTokensProvider: NetworkTokensProvider(),
          ),
        ),
        BlocProvider<TransactionsCubit>.value(value: transactionsCubit),
      ],
      child: MaterialApp.router(
        theme: ThemeData(extensions: [GWColors.dark()]),
        routerConfig: router,
      ),
    ),
  );
  unawaited(router.push('/send'));
  await tester.pumpAndSettle();
  return router;
}

Future<void> _openReview(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).at(0), _recipient);
  await tester.enterText(find.byType(TextField).at(1), '0.5');
  await tester.pump();
  await tester.tap(find.widgetWithText(GWButton, 'Review'));
  await tester.pumpAndSettle();
}

void main() {
  group('inside the app shell', () {
    testWidgets('Send in the review drawer signs and keeps the page', (
      tester,
    ) async {
      final api = _FakeApi();
      await _mountInShell(
        tester,
        api,
        _RecordingStorage(),
        TransactionsCubit(),
      );
      await _openReview(tester);
      expect(find.text('Gas Fee'), findsOneWidget);

      await tester.tap(find.widgetWithText(GWButton, 'Send'));
      await tester.pumpAndSettle();

      expect(api.signedTx, isNotNull);
      expect(find.byType(SendScreen), findsOneWidget);
    });

    testWidgets('Cancel closes only the drawer', (tester) async {
      final api = _FakeApi();
      await _mountInShell(
        tester,
        api,
        _RecordingStorage(),
        TransactionsCubit(),
      );
      await _openReview(tester);

      await tester.tap(find.widgetWithText(GWButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Gas Fee'), findsNothing);
      expect(find.byType(SendScreen), findsOneWidget);
      expect(api.signedTx, isNull);
    });

    testWidgets('leaving /send under an open drawer, then dismissing it, '
        'touches no closed cubit', (tester) async {
      final api = _FakeApi();
      await _mountInShell(
        tester,
        api,
        _RecordingStorage(),
        TransactionsCubit(),
      );
      await _openReview(tester);

      // Pops /send off the shell's navigator, beneath the drawer.
      Navigator.of(tester.element(find.byType(SendScreen))).pop();
      await tester.pumpAndSettle();
      expect(find.byType(SendScreen), findsNothing);

      Navigator.of(
        tester.element(find.text('Gas Fee')),
        rootNavigator: true,
      ).pop();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(api.signedTx, isNull);
    });

    testWidgets('leaving /send under an open drawer, then tapping Send, '
        'signs nothing and touches no closed cubit', (tester) async {
      final api = _FakeApi();
      await _mountInShell(
        tester,
        api,
        _RecordingStorage(),
        TransactionsCubit(),
      );
      await _openReview(tester);

      Navigator.of(tester.element(find.byType(SendScreen))).pop();
      await tester.pumpAndSettle();
      expect(find.byType(SendScreen), findsNothing);

      await tester.tap(find.widgetWithText(GWButton, 'Send'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(api.signedTx, isNull);
    });
  });

  testWidgets(
    'send 0.5 MATIC on Amoy: form, fee, review, sign, pending, completed',
    (tester) async {
      final api = _FakeApi();
      final storage = _RecordingStorage();
      final transactionsCubit = TransactionsCubit();
      await _mount(tester, api, storage, transactionsCubit);

      await tester.enterText(find.byType(TextField).at(0), _recipient);
      await tester.enterText(find.byType(TextField).at(1), '0.5');
      await tester.pump();

      await tester.tap(find.widgetWithText(GWButton, 'Review'));
      await tester.pumpAndSettle();

      // The review drawer shows the fee in the gas coin, before approval.
      expect(find.text('Gas Fee'), findsOneWidget);
      expect(find.textContaining('MATIC'), findsWidgets);

      await tester.tap(find.widgetWithText(GWButton, 'Send'));
      await tester.pumpAndSettle();

      // The signed map: the recipient, the raw amount, no calldata.
      final tx = api.signedTx;
      expect(tx, isNotNull);
      expect((tx!['to'] as String).toLowerCase(), _recipient.toLowerCase());
      expect(parseHexToBigInt(tx['value']), BigInt.parse('500000000000000000'));
      expect(tx.containsKey('data'), isFalse);
      expect(parseHexToBigInt(tx['maxFeePerGas']), isNot(BigInt.zero));

      // History: pending written before the resolved row, same hash.
      expect(storage.writes.length, 2);
      expect(storage.writes[0].transactionStatus, TransactionStatus.pending);
      expect(storage.writes[1].transactionStatus, TransactionStatus.completed);
      expect(storage.writes[0].hash, _hash);
      expect(storage.writes[1].hash, _hash);

      // TransactionsCubit gets the resolved row exactly once.
      expect(transactionsCubit.state.length, 1);
      expect(transactionsCubit.state.first.assetSymbol, 'MATIC');
      expect(transactionsCubit.state.first.chainId, 80002);
      expect(
        transactionsCubit.state.first.transactionStatus,
        TransactionStatus.completed,
      );
    },
  );

  testWidgets(
    'a failed review keeps its error under the amount field, not a toast',
    (tester) async {
      final api = _FakeApi();
      final storage = _RecordingStorage();
      final transactionsCubit = TransactionsCubit();
      await _mount(tester, api, storage, transactionsCubit);

      // A valid recipient with an amount the seeded 10 MATIC balance can't
      // cover: the error is about the amount, so it belongs under Amount.
      await tester.enterText(find.byType(TextField).at(0), _recipient);
      await tester.enterText(find.byType(TextField).at(1), '999');
      await tester.pump();

      await tester.tap(find.widgetWithText(GWButton, 'Review'));
      await tester.pumpAndSettle();

      const message = 'Not enough MATIC to cover the amount and the fee.';
      expect(
        find.descendant(
          of: find.byWidgetPredicate(
            (w) => w is GWTextField && w.label == 'Amount',
          ),
          matching: find.text(message),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(RecipientField),
          matching: find.text(message),
        ),
        findsNothing,
      );
      // The drawer never opened -- review refused before a review was built.
      expect(find.text('Gas Fee'), findsNothing);
    },
  );

  testWidgets(
    'the drawer shows a 6-decimal token in its own units, chain and contract',
    (tester) async {
      await _mount(
        tester,
        _FakeApi(),
        _RecordingStorage(),
        TransactionsCubit(),
        symbol: 'usdc',
        address: _usdcCoin.address,
      );

      await tester.enterText(find.byType(TextField).at(0), _recipient);
      await tester.enterText(find.byType(TextField).at(1), '100');
      await tester.pump();
      await tester.tap(find.widgetWithText(GWButton, 'Review'));
      await tester.pumpAndSettle();

      expect(find.text('100 USDC'), findsOneWidget);
      expect(find.text('0.00063 MATIC'), findsOneWidget);
      // The chain and the contract, since the same symbol lives on many.
      expect(find.text('Polygon Amoy'), findsOneWidget);
      expect(find.text('Token'), findsOneWidget);
    },
  );

  testWidgets('a fee that cannot be read is said above Review, not under To', (
    tester,
  ) async {
    await _mount(
      tester,
      _FakeApi(feeFails: true),
      _RecordingStorage(),
      TransactionsCubit(),
    );
    await tester.enterText(find.byType(TextField).at(0), _recipient);
    await tester.enterText(find.byType(TextField).at(1), '0.5');
    await tester.pump();
    await tester.tap(find.widgetWithText(GWButton, 'Review'));
    await tester.pumpAndSettle();

    const message = "Couldn't estimate the network fee.";
    expect(
      find.descendant(
        of: find.byType(GWWarningNote),
        matching: find.text(message),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(RecipientField),
        matching: find.text(message),
      ),
      findsNothing,
    );
  });

  testWidgets('a send the chain reverted is reported as failed, not sent', (
    tester,
  ) async {
    await _mount(
      tester,
      _FakeApi(receiptStatus: '0x0'),
      _RecordingStorage(),
      TransactionsCubit(),
    );
    await tester.enterText(find.byType(TextField).at(0), _recipient);
    await tester.enterText(find.byType(TextField).at(1), '0.5');
    await tester.pump();
    await tester.tap(find.widgetWithText(GWButton, 'Review'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(GWButton, 'Send'));
    await tester.pumpAndSettle();

    expect(find.text('Send failed'), findsOneWidget);
    expect(find.textContaining('Sent to'), findsNothing);
  });

  testWidgets('the review drawer fits a short screen with large text, and '
      'Send in its footer still signs', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final api = _FakeApi();
    await _mount(
      tester,
      api,
      _RecordingStorage(),
      TransactionsCubit(),
      symbol: 'usdc',
      address: _usdcCoin.address,
      size: const Size(320, 480),
    );

    await tester.enterText(find.byType(TextField).at(0), _recipient);
    await tester.enterText(find.byType(TextField).at(1), '100');
    await tester.pump();
    final review = find.widgetWithText(GWButton, 'Review');
    await tester.ensureVisible(review);
    await tester.pumpAndSettle();
    await tester.tap(review);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // The last detail row is scrolled to, not cut off.
    final priority = find.text('Priority Fee');
    await tester.ensureVisible(priority);
    await tester.pumpAndSettle();
    expect(tester.getRect(priority).bottom, lessThanOrEqualTo(480));

    final send = find.widgetWithText(GWButton, 'Send');
    expect(tester.getRect(send).bottom, lessThanOrEqualTo(480));
    await tester.tap(send);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(api.signedTx, isNotNull);
  });

  testWidgets('Review stays reachable on a short screen with large text and '
      'the keyboard up', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _mount(
      tester,
      // An unreadable fee keeps the review drawer shut: its note appearing
      // is the proof the tap reached Review.
      _FakeApi(recipientIsContract: true, feeFails: true),
      _RecordingStorage(),
      TransactionsCubit(),
      size: const Size(320, 480),
    );
    tester.view.viewInsets = const FakeViewPadding(bottom: 200);

    await tester.enterText(find.byType(TextField).at(0), _recipient);
    await tester.enterText(find.byType(TextField).at(1), '0.5');
    await tester.pump();
    expect(find.byType(GWWarningNote), findsOneWidget);

    final review = find.widgetWithText(GWButton, 'Review');
    await tester.ensureVisible(review);
    await tester.pumpAndSettle();
    await tester.tap(review);
    await tester.pumpAndSettle();

    expect(find.text("Couldn't estimate the network fee."), findsOneWidget);
    await tester.ensureVisible(review);
    await tester.pumpAndSettle();
    expect(tester.getRect(review).bottom, lessThanOrEqualTo(280));
  });

  testWidgets('tapping MAX puts the cubit-computed amount into the field', (
    tester,
  ) async {
    final api = _FakeApi();
    final storage = _RecordingStorage();
    final transactionsCubit = TransactionsCubit();
    await _mount(tester, api, storage, transactionsCubit);

    await tester.tap(find.widgetWithText(GWButton, 'MAX'));
    await tester.pumpAndSettle();

    // 10 MATIC (the seeded native balance) minus the fake fee's maxCost.
    expect(find.text('9.99937'), findsOneWidget);
  });

  testWidgets(
    'a bare /send offers the held coins; picking one seats the form',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<WalletDetailsCubit>(
              create: (_) => _SeededCubit(
                geniusApi: _FakeApi(),
                networkTokensProvider: NetworkTokensProvider(),
              ),
            ),
            BlocProvider<TransactionsCubit>(create: (_) => TransactionsCubit()),
          ],
          child: MaterialApp(
            theme: ThemeData(extensions: [GWColors.dark()]),
            home: const SendScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CoinsScreen), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      await tester.tap(find.byType(CoinCardRow).first);
      await tester.pump();

      expect(find.byType(CoinsScreen), findsNothing);
      expect(find.byType(TextField), findsWidgets);
    },
  );

  testWidgets('no wallet renders a GWEmptyState and no form', (tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<WalletDetailsCubit>(
            create: (_) => WalletDetailsCubit(
              initialState: const WalletDetailsState(
                selectedNetwork: _amoy,
                coins: [_maticCoin],
              ),
              geniusApi: _FakeApi(),
              networkTokensProvider: NetworkTokensProvider(),
            ),
          ),
          BlocProvider<TransactionsCubit>(create: (_) => TransactionsCubit()),
        ],
        child: MaterialApp(
          theme: ThemeData(extensions: [GWColors.dark()]),
          home: const SendScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(GWEmptyState), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(CoinsScreen), findsNothing);
  });

  testWidgets('a watch-only wallet renders a GWEmptyState and no form', (
    tester,
  ) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<WalletDetailsCubit>(
            create: (_) => WalletDetailsCubit(
              initialState: const WalletDetailsState(
                selectedWallet: Wallet(
                  coinType: TWCoinType.TWCoinTypeEthereum,
                  walletName: 'Watched',
                  currencySymbol: 'MATIC',
                  walletType: WalletType.tracking,
                  balance: 0,
                  address: _walletAddress,
                ),
                selectedNetwork: _amoy,
                coins: [_maticCoin],
              ),
              geniusApi: _FakeApi(),
              networkTokensProvider: NetworkTokensProvider(),
            ),
          ),
          BlocProvider<TransactionsCubit>(create: (_) => TransactionsCubit()),
        ],
        child: MaterialApp(
          theme: ThemeData(extensions: [GWColors.dark()]),
          home: const SendScreen(preselectSymbol: 'matic'),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(GWEmptyState), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets(
    'a network that fails canSignOn renders a GWEmptyState and no form',
    (tester) async {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<WalletDetailsCubit>(
              create: (_) => WalletDetailsCubit(
                initialState: const WalletDetailsState(
                  selectedWallet: _wallet,
                  selectedNetwork: _unsignableNetwork,
                  coins: [_maticCoin],
                ),
                geniusApi: _FakeApi(),
                networkTokensProvider: NetworkTokensProvider(),
              ),
            ),
            BlocProvider<TransactionsCubit>(create: (_) => TransactionsCubit()),
          ],
          child: MaterialApp(
            theme: ThemeData(extensions: [GWColors.dark()]),
            home: const SendScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(GWEmptyState), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    },
  );

  testWidgets('switching the selected network rebuilds a fresh form', (
    tester,
  ) async {
    final api = _FakeApi();
    final storage = _RecordingStorage();
    final transactionsCubit = TransactionsCubit();
    late _SeededCubit walletCubit;

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<WalletDetailsCubit>(
            create: (_) {
              walletCubit = _SeededCubit(
                geniusApi: api,
                networkTokensProvider: NetworkTokensProvider(),
              );
              return walletCubit;
            },
          ),
          BlocProvider<TransactionsCubit>.value(value: transactionsCubit),
        ],
        child: MaterialApp(
          theme: ThemeData(extensions: [GWColors.dark()]),
          // No preselectChainId: the same 'matic' symbol resolves on any
          // chain here, so the fresh-form assertion below is about the
          // cubit instance, not a coin that stopped matching.
          home: SendScreen(preselectSymbol: 'matic', storage: storage),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField).at(0), _recipient);
    await tester.pump();
    expect(find.text(_recipient), findsOneWidget);

    walletCubit.debugSelectNetwork(_ethereum);
    walletCubit.debugCoinsLoaded(_ethereum, const [
      // No address: a symbol-only preselect seats only a native coin.
      Coin(symbol: 'matic', decimals: '18', balance: 1),
    ]);
    await tester.pump();

    // The wallet+chainId key changed, so a fresh SendCubit was built --
    // the typed recipient from the old one is gone, not carried over.
    expect(find.text(_recipient), findsNothing);
    expect(find.byType(TextField), findsWidgets);
  });

  group('coins from the network you just left', () {
    testWidgets('Polygon to Ethereum: a MATIC preselect seats nothing', (
      tester,
    ) async {
      final walletCubit = _SeededCubit(
        geniusApi: _FakeApi(),
        networkTokensProvider: NetworkTokensProvider(),
      );
      addTearDown(walletCubit.close);
      walletCubit.debugSelectNetwork(_ethereum);

      await _mountOver(tester, walletCubit, symbol: 'matic');

      expect(_sendCubitProvider, findsNothing);
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(CoinsScreen), findsNothing);
      expect(find.textContaining('Ethereum'), findsOneWidget);
    });

    testWidgets('a bare /send offers no picker over the old list', (
      tester,
    ) async {
      final walletCubit = _SeededCubit(
        geniusApi: _FakeApi(),
        networkTokensProvider: NetworkTokensProvider(),
      );
      addTearDown(walletCubit.close);
      walletCubit.debugSelectNetwork(_ethereum);

      await _mountOver(tester, walletCubit);

      expect(_sendCubitProvider, findsNothing);
      expect(find.byType(CoinsScreen), findsNothing);
    });

    testWidgets('Ethereum to Sepolia: a mainnet token preselect seats '
        'nothing', (tester) async {
      final walletCubit = _SeededCubit(
        geniusApi: _FakeApi(),
        networkTokensProvider: NetworkTokensProvider(),
      );
      addTearDown(walletCubit.close);
      walletCubit.debugSelectNetwork(_ethereum);
      walletCubit.debugCoinsLoaded(_ethereum, const [_mainnetUsdc]);
      walletCubit.debugSelectNetwork(_sepolia);

      await _mountOver(
        tester,
        walletCubit,
        symbol: 'usdc',
        address: _mainnetUsdc.address,
      );

      expect(_sendCubitProvider, findsNothing);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets("once the new network's coins load, the preselect seats", (
      tester,
    ) async {
      final walletCubit = _SeededCubit(
        geniusApi: _FakeApi(),
        networkTokensProvider: NetworkTokensProvider(),
      );
      addTearDown(walletCubit.close);
      walletCubit.debugSelectNetwork(_ethereum);
      await _mountOver(tester, walletCubit, symbol: 'eth');
      expect(find.byType(TextField), findsNothing);

      walletCubit.debugCoinsLoaded(_ethereum, const [
        Coin(symbol: 'eth', networkSymbol: 'eth', balance: 1),
      ]);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsWidgets);
      expect(find.text('ETH'), findsOneWidget);
    });
  });

  group('a token page seats that exact token', () {
    // Two contracts on one chain can share a ticker; only the address says
    // which one the user was looking at.
    const bridgedUsdc = Coin(
      symbol: 'usdc',
      address: '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174',
      decimals: '6',
      balance: 500,
    );
    const coins = [_maticCoin, _usdcCoin, bridgedUsdc];

    testWidgets('the second of two same-ticker tokens signs to its own '
        'contract', (tester) async {
      final api = _FakeApi();
      await _mount(
        tester,
        api,
        _RecordingStorage(),
        TransactionsCubit(),
        symbol: 'usdc',
        address: bridgedUsdc.address!.toLowerCase(),
        coins: coins,
      );

      await tester.enterText(find.byType(TextField).at(0), _recipient);
      await tester.enterText(find.byType(TextField).at(1), '100');
      await tester.pump();
      await tester.tap(find.widgetWithText(GWButton, 'Review'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(GWButton, 'Send'));
      await tester.pumpAndSettle();

      final tx = api.signedTx;
      expect(tx, isNotNull);
      expect(
        (tx!['to'] as String).toLowerCase(),
        bridgedUsdc.address!.toLowerCase(),
      );
    });

    testWidgets('an address the wallet does not hold seats nothing', (
      tester,
    ) async {
      await _mount(
        tester,
        _FakeApi(),
        _RecordingStorage(),
        TransactionsCubit(),
        symbol: 'usdc',
        address: '0x000000000000000000000000000000000000dEaD',
        coins: coins,
      );

      expect(find.byType(CoinsScreen), findsOneWidget);
    });

    testWidgets('no address seats only the native coin, never a token', (
      tester,
    ) async {
      await _mount(
        tester,
        _FakeApi(),
        _RecordingStorage(),
        TransactionsCubit(),
        symbol: 'usdc',
        coins: coins,
      );
      expect(find.byType(CoinsScreen), findsOneWidget);
    });

    testWidgets('the native coin still seats with no address', (tester) async {
      await _mount(
        tester,
        _FakeApi(),
        _RecordingStorage(),
        TransactionsCubit(),
        coins: coins,
      );
      expect(find.byType(CoinsScreen), findsNothing);
      expect(find.text('MATIC'), findsWidgets);
    });
  });
}
