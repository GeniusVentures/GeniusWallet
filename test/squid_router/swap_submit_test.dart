// The screen's half of "no hash, no side effects".
//
// 26-05 proved the pure function returns all-false for every outcome without a
// hash. That is not the same as the screen OBEYING it — the original bug was a
// correct-looking screen deciding for itself that a swap had succeeded. These
// cases assert what the screen DID: what it stored, what it toasted, what it
// opened. Driven through a stubbed orchestrator, so no network, no key and no
// real Hive box are involved (real Hive I/O inside testWidgets hangs here).
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/services/transaction_storage_service.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/squid_router/route_details_card.dart';
import 'package:genius_wallet/squid_router/swap_execution.dart';
import 'package:genius_wallet/squid_router/swap_field.dart';
import 'package:genius_wallet/squid_router/swap_messages.dart';
import 'package:genius_wallet/squid_router/swap_screen.dart';
import 'package:genius_wallet/swap/swap_quote.dart';
import 'package:genius_wallet/swap/swap_token.dart';
import 'package:genius_wallet/swap/swap_transaction.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

import '../swap/fake_swap_provider.dart';

const _hash = '0xfeedfacefeedfacefeedfacefeedfacefeedface';
const _native = '0x0000000000000000000000000000000000000000';
const _dai = '0x6B175474E89094C44Da98b954EedeAC495271d0F';

SwapTransaction _route() => const SwapTransaction(
  quoteId: 'q1',
  requestId: 'r1',
  spender: '0xce16F69375520ab01377ce7B88f5BA8C48F8D666',
  request: {'from': '0x1', 'to': '0x2', 'value': '0x0', 'data': '0xda7a'},
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

/// Answers the catalogue and a quote so the CTA can reach its ready rung.
/// It never executes anything — the orchestrator is stubbed separately.
class _Provider extends FakeSwapProvider {
  const _Provider();

  @override
  Future<List<SwapToken>> tokens(String chainId) async => [
    SwapToken(
      chainId: '1',
      address: _native,
      name: 'Ethereum',
      symbol: 'ETH',
      decimals: 18,
      rawBalance: BigInt.parse('5000000000000000000'),
    ),
    const SwapToken(
      chainId: '1',
      address: _dai,
      name: 'Dai Stablecoin',
      symbol: 'DAI',
      decimals: 18,
    ),
  ];

  @override
  Future<SwapQuote> quote(SwapQuoteRequest request) async => SwapQuote(
    id: 'q1',
    exchangeRate: '2500',
    priceImpact: '0.02',
    fromAmount: BigInt.parse('1000000000000000000'),
    toAmount: BigInt.parse('2500000000000000000000'),
    toAmountMin: BigInt.parse('2490000000000000000000'),
    fromAmountDisplay: '1',
    toAmountDisplay: '2500',
    feesUsd: 0,
    gasUsd: 0.42,
    estimatedDuration: const Duration(seconds: 20),
  );
}

class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

const _wallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Swap Wallet',
  currencySymbol: 'ETH',
  walletType: WalletType.mnemonic,
  balance: 0,
  address: '0xSWAPSWAPSWAPSWAPSWAPSWAPSWAPSWAPSWAPSWAP',
);

class _SeededCubit extends WalletDetailsCubit {
  _SeededCubit({
    required super.geniusApi,
    required super.networkTokensProvider,
  }) {
    emit(
      state.copyWith(
        selectedWallet: _wallet,
        selectedNetwork: const Network(
          name: 'Ethereum',
          symbol: 'ETH',
          chainId: 1,
          rpcUrl: 'https://rpc.invalid',
        ),
        selectedWalletBalance: '5',
      ),
    );
  }
}

/// Mounts the screen and drives it to the ready rung: ETH is preselected onto
/// the pay side because the wallet holds it, DAI is chosen on the receive
/// side, and an amount is typed so the stubbed quote resolves.
Future<void> _mountReady(
  WidgetTester tester, {
  required SwapExecutor execute,
  required TransactionStorageService storage,
}) async {
  tester.view.physicalSize = const Size(1200, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<WalletDetailsCubit>(
          create: (_) => _SeededCubit(
            geniusApi: _UnusedApi(),
            networkTokensProvider: NetworkTokensProvider(),
          ),
        ),
        BlocProvider<TransactionsCubit>(create: (_) => TransactionsCubit()),
      ],
      child: MaterialApp(
        theme: ThemeData(extensions: [GWColors.dark()]),
        home: SwapScreen(
          swapAvailable: true,
          preselectSymbol: 'ETH',
          preselectChainId: 1,
          provider: const _Provider(),
          execute: execute,
          storage: storage,
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();

  // Seat the receive token through the picker the user would use.
  await tester.tap(find.text('Select'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Dai Stablecoin'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextField).first, '1');
  await tester.pump();
  // Past the 1000ms quote debounce, so the stubbed quote lands.
  await tester.pump(const Duration(milliseconds: 1200));
  await tester.pump();
}

/// An orchestrator that runs nothing and answers [outcome].
SwapExecutor _answering(SwapOutcome outcome) =>
    ({
      required tokenAddress,
      required amount,
      required fetchRoute,
      required readAllowance,
      required approve,
      required send,
      required readStatus,
      required wait,
      pollAttempts = 20,
      pollInterval = const Duration(seconds: 3),
    }) async => outcome;

/// The CTA, NOT the page header — which is also titled "Swap". Tapping the
/// title silently does nothing and makes every assertion below vacuous.
final _cta = find.widgetWithText(GWButton, 'Swap');

Future<void> _submit(WidgetTester tester) async {
  await tester.tap(_cta);
  await tester.pump();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'the ready rung is reachable, so the cases below mean something',
    (tester) async {
      final storage = _RecordingStorage();
      await _mountReady(
        tester,
        execute: _answering(const SwapRouteUnavailable(null)),
        storage: storage,
      );

      // Guards the fixture itself: without this the taps below hit nothing
      // and every assertion passes for the wrong reason. It has already
      // caught one such case — the page header is titled "Swap" too.
      expect(_cta, findsOneWidget);
      expect(find.text('Retry'), findsNothing, reason: 'the quote failed');
    },
  );

  group('an outcome with no hash', () {
    for (final outcome in <SwapOutcome>[
      const SwapRouteUnavailable(null),
      const SwapApprovalFailed(null),
      const SwapSendFailed(null),
    ]) {
      testWidgets('${outcome.runtimeType} stores nothing and claims nothing', (
        tester,
      ) async {
        final storage = _RecordingStorage();
        await _mountReady(
          tester,
          execute: _answering(outcome),
          storage: storage,
        );
        await _submit(tester);

        expect(storage.writes, isEmpty, reason: 'wrote a row with no hash');
        expect(find.text('Swap Submitted'), findsNothing);
        // The receipt sheet would carry the hash label; nothing opens it.
        expect(find.textContaining('0xfeedface'), findsNothing);
      });
    }

    testWidgets('the CTA leaves its submitting rung', (tester) async {
      final storage = _RecordingStorage();
      await _mountReady(
        tester,
        execute: _answering(const SwapSendFailed(null)),
        storage: storage,
      );
      await _submit(tester);

      expect(find.text('Submitting swap…'), findsNothing);
    });

    // One mount per case: Flutter reuses the State object across a repeated
    // pumpWidget, so a loop inside one case would find the tokens already
    // seated and tap nothing.
    for (final outcome in <SwapOutcome>[
      const SwapRouteUnavailable(null),
      const SwapAllowanceUnreadable(null),
      const SwapSendFailed(null),
    ]) {
      testWidgets('${outcome.runtimeType} names itself on screen', (
        tester,
      ) async {
        // Not just "a message appeared" — the message BELONGING to that
        // branch. A shared fallback would pass a weaker assertion.
        final storage = _RecordingStorage();
        await _mountReady(
          tester,
          execute: _answering(outcome),
          storage: storage,
        );
        await _submit(tester);

        expect(find.text(swapFailureMessage(outcome)!), findsWidgets);
      });
    }

    testWidgets('a failure clears the quote it failed on', (tester) async {
      // A stale figure beside a failure message is a number the user might
      // still act on.
      final storage = _RecordingStorage();
      await _mountReady(
        tester,
        execute: _answering(const SwapSendFailed(null)),
        storage: storage,
      );
      expect(
        find.byType(RouteDetailsCard),
        findsOneWidget,
        reason: 'the fixture never had a quote to clear',
      );

      await _submit(tester);

      expect(find.byType(RouteDetailsCard), findsNothing);
      final receive = tester.widget<SwapField>(find.byType(SwapField).at(1));
      expect(receive.controller.text, isEmpty);
    });
  });

  group('a broadcast swap', () {
    testWidgets('writes pending first, then the resolved status, one key', (
      tester,
    ) async {
      final storage = _RecordingStorage();
      await _mountReady(
        tester,
        execute: _answering(
          SwapBroadcast(
            hash: _hash,
            status: TransactionStatus.completed,
            transaction: _route(),
          ),
        ),
        storage: storage,
      );
      await _submit(tester);

      expect(storage.writes, hasLength(2));
      // Pending BEFORE the resolved status: a crash mid-poll must leave an
      // accurate record of funds that already moved, not nothing.
      expect(storage.writes.first.transactionStatus, TransactionStatus.pending);
      expect(
        storage.writes.last.transactionStatus,
        TransactionStatus.completed,
      );
      // One key, so the second write resolves the first rather than adding a
      // second row. The fabricated record used to key every swap on ''.
      expect(storage.writes.map((t) => t.hash).toSet(), {_hash});
    });

    testWidgets('carries the real fee, and the swap type', (tester) async {
      final storage = _RecordingStorage();
      await _mountReady(
        tester,
        execute: _answering(
          SwapBroadcast(
            hash: _hash,
            status: TransactionStatus.completed,
            transaction: _route(),
          ),
        ),
        storage: storage,
      );
      await _submit(tester);

      final row = storage.writes.last;
      expect(row.type, TransactionType.swap);
      // Something executed, so a gas figure exists and belongs on the row.
      expect(row.fees, isNotEmpty);
      expect(row.fees, isNot('0.00'));
    });

    testWidgets('a non-success status is still recorded, not hidden', (
      tester,
    ) async {
      // The funds moved. Dropping the row because the outcome was partial is
      // the same class of lie as showing one when nothing moved.
      final storage = _RecordingStorage();
      await _mountReady(
        tester,
        execute: _answering(
          SwapBroadcast(
            hash: _hash,
            status: TransactionStatus.partialSuccess,
            transaction: _route(),
          ),
        ),
        storage: storage,
      );
      await _submit(tester);

      expect(storage.writes, hasLength(2));
      expect(
        storage.writes.last.transactionStatus,
        TransactionStatus.partialSuccess,
      );
    });

    testWidgets('the CTA leaves its submitting rung', (tester) async {
      final storage = _RecordingStorage();
      await _mountReady(
        tester,
        execute: _answering(
          SwapBroadcast(
            hash: _hash,
            status: TransactionStatus.completed,
            transaction: _route(),
          ),
        ),
        storage: storage,
      );
      await _submit(tester);

      expect(find.text('Submitting swap…'), findsNothing);
    });
  });
}
