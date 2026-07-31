// Wiring test for `WalletsOverview` - the compute panel host
// (`lib/components/wallet_overview.dart`, `14-08-PLAN.md` Task 1).
//
// Proves this file feeds `resolveComputeState`/`viewForComputeState` from
// the right live sources (the wallet selection, the SGNUS connection
// stream, the app bloc's feed fields) and wires the retry affordance to a
// real dispatched event - NOT the state resolution logic itself (already
// proven pure by `test/dashboard/compute_state_test.dart`) and NOT the
// panel's own rendering (already proven by
// `test/dashboard/compute_panel_height_test.dart`/
// `test/theme/compute_contrast_test.dart`). This file is a wiring test, kept
// deliberately narrow.
//
// In particular: a disconnected SGNUS node must resolve to "Disconnected",
// never "Not linked" - `wallet_overview.dart:179` used to pass
// `connection?.walletAddress ?? ""` into the linked-wallet comparison, which
// made every wallet test as "not linked" whenever the node was offline. That
// false accusation (`T-14-30`) is closed by precedence in
// `compute_state.dart`; this test proves the precedence survives the real
// wiring, not just the pure resolver's own unit tests.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/wallet_overview.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// Hand-written fake - `implements` + `noSuchMethod` forward, the same
/// pattern `test/account/account_drawer_show_test.dart` and
/// `test/submit_job/job_flow_test.dart` established, because the real
/// `GeniusApi`'s constructor dlopens the native SuperGenius framework and
/// crashes `flutter test`'s host environment.
///
/// Only the three calls this card actually makes are given real behavior.
/// Everything else - including every call `SubmitJobCubit`/`GnusCubit` could
/// make once constructed - is never reached: this harness never selects a
/// network (see `_build` below), which both cubits' own early-return guards
/// intercept before touching `geniusApi` at all, and neither cubit's flow
/// methods (`openFilePicker`, `bridgeTokens`, ...) are ever invoked here.
class _FakeGeniusApi implements GeniusApi {
  _FakeGeniusApi()
    : _connectionController = StreamController<SGNUSConnection>.broadcast();

  final StreamController<SGNUSConnection> _connectionController;
  String gnusBalance = '0';
  String minionsBalance = '0';

  void emitConnection(SGNUSConnection connection) {
    _connectionController.add(connection);
  }

  @override
  Stream<SGNUSConnection> getSGNUSConnectionStream() =>
      _connectionController.stream;

  @override
  String getSGNUSBalance() => gnusBalance;

  @override
  String getMinionsBalance([String? tokenId]) => minionsBalance;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Seeds `AppBloc.state` directly after construction, bypassing
/// `LoadWallets`/`ProcessingStatusTicked` - the same seeding pattern
/// `test/account/account_drawer_show_test.dart`'s `_SeededAppBloc` and
/// `test/submit_job/job_flow_test.dart`'s `_Seeded*` cubits use. The real
/// `on<RetryProcessingStatus>` handler is deliberately NOT overridden -
/// proving that real handler runs, unmodified, is the whole point of the
/// retry test below.
class _SeededAppBloc extends AppBloc {
  _SeededAppBloc({
    required super.api,
    required super.transactionsCubit,
    required super.walletDetailsCubit,
    required super.networkProvider,
    ProcessingFeedStatus processingFeedStatus =
        ProcessingFeedStatus.neverTicked,
  }) {
    emit(state.copyWith(processingFeedStatus: processingFeedStatus));
  }
}

/// Seeds `WalletDetailsCubit.state.selectedWallet` directly from within a
/// subclass constructor - `emit` is `@protected`, and every `_Seeded*`
/// cubit in this codebase (`account_drawer_show_test.dart`'s
/// `_SeededAppBloc`, `job_flow_test.dart`'s `_SeededGnusCubit`/
/// `_SeededSubmitJobCubit`) follows the same shape rather than calling
/// `.emit(...)` on an instance from outside its class.
class _SeededWalletDetailsCubit extends WalletDetailsCubit {
  _SeededWalletDetailsCubit({
    required super.geniusApi,
    required super.networkTokensProvider,
    required Wallet selectedWallet,
  }) {
    emit(state.copyWith(selectedWallet: selectedWallet));
  }
}

const _linkedWallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Linked Wallet',
  currencySymbol: 'GNUS',
  walletType: WalletType.sgnus,
  balance: 0,
  address: '0xLINKEDLINKEDLINKEDLINKEDLINKEDLINKEDLINK',
);

class _Harness {
  _Harness(this.geniusApi, this.walletDetailsCubit, this.appBloc);

  final _FakeGeniusApi geniusApi;
  final WalletDetailsCubit walletDetailsCubit;
  final AppBloc appBloc;

  /// Mirrors `account_drawer_show_test.dart`'s own harness note:
  /// `AppBloc.close()` awaits its internal event-stream settling, and its
  /// constructor starts a real 3s poll `Timer` (`_startInitPolling`) - both
  /// hang under plain `FakeAsync` the same way real disk I/O does.
  Future<void> dispose(WidgetTester tester) async {
    await tester.runAsync(() => appBloc.close());
    await walletDetailsCubit.close();
  }
}

/// [selectedNetwork] is deliberately left `null` throughout this file - the
/// widget under test creates its own `GnusCubit`/`SubmitJobCubit` in
/// `initState` (this is that subtree's whole point per `14-08-PLAN.md` Task
/// 1: it owns the job cubit so a drawer barrier tap can never destroy an
/// in-flight hash), and both cubits' own `network == null` guards
/// (`gnus_cubit.dart:48,73`) short-circuit before either ever calls
/// `geniusApi` or touches the filesystem/network - which is what keeps this
/// widget test hermetic without a second fake.
_Harness _build({
  ProcessingFeedStatus processingFeedStatus = ProcessingFeedStatus.neverTicked,
}) {
  final geniusApi = _FakeGeniusApi();
  final walletDetailsCubit = _SeededWalletDetailsCubit(
    geniusApi: geniusApi,
    networkTokensProvider: NetworkTokensProvider(),
    selectedWallet: _linkedWallet,
  );
  final appBloc = _SeededAppBloc(
    api: geniusApi,
    transactionsCubit: TransactionsCubit(),
    walletDetailsCubit: walletDetailsCubit,
    networkProvider: NetworkProvider(),
    processingFeedStatus: processingFeedStatus,
  );
  return _Harness(geniusApi, walletDetailsCubit, appBloc);
}

Widget _host({required _Harness harness}) => MultiBlocProvider(
  providers: [
    BlocProvider<WalletDetailsCubit>.value(value: harness.walletDetailsCubit),
    BlocProvider<AppBloc>.value(value: harness.appBloc),
  ],
  child: MaterialApp(
    theme: ThemeData.dark().copyWith(extensions: [GWColors.dark()]),
    home: Scaffold(
      body: WalletsOverview(geniusApi: harness.geniusApi, account: null),
    ),
  ),
);

/// Unmounts the widget tree (running `WalletsOverviewState.dispose`, which
/// cancels its own balance-poll `Timer`) before closing the bloc/cubit
/// harness - mirrored from the same ordering concern
/// `account_drawer_show_test.dart`'s own teardown documents: a pending
/// `Timer` left after the test body returns trips `flutter_test`'s own
/// end-of-test invariant.
Future<void> _teardown(WidgetTester tester, _Harness harness) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await harness.dispose(tester);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'a disconnected node resolves to Disconnected, never Not linked - the '
    'false-accusation bug wallet_overview.dart:179 used to cause',
    (tester) async {
      final harness = _build();
      try {
        await tester.pumpWidget(_host(harness: harness));
        await tester.pump();

        // isConnected: false with an EMPTY walletAddress - exactly what the
        // real SGNUSConnection.empty() reports, and exactly the shape that
        // used to make every wallet compare unequal to "" and read as
        // not-linked instead of disconnected.
        harness.geniusApi.emitConnection(
          const SGNUSConnection(
            sgnusAddress: '',
            walletAddress: '',
            isConnected: false,
          ),
        );
        // A broadcast StreamController's `.add()` delivers on a microtask; a
        // single `pump()` is not always enough to flush both the stream
        // delivery AND the StreamBuilder's own follow-up setState in one
        // pass, so every emission in this file is followed by two.
        await tester.pump();
        await tester.pump();

        expect(find.text('Disconnected'), findsOneWidget);
        expect(find.text('Not linked'), findsNothing);
      } finally {
        await _teardown(tester, harness);
      }
    },
  );

  testWidgets('a connected node whose address differs from the selected wallet '
      'resolves to Not linked', (tester) async {
    final harness = _build();
    try {
      await tester.pumpWidget(_host(harness: harness));
      await tester.pump();

      harness.geniusApi.emitConnection(
        const SGNUSConnection(
          sgnusAddress: '0xNODE',
          walletAddress: '0xSOMEOTHERWALLETADDRESSNOTLINKEDATALL0000',
          isConnected: true,
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Not linked'), findsOneWidget);
      expect(find.text('Disconnected'), findsNothing);
    } finally {
      await _teardown(tester, harness);
    }
  });

  testWidgets(
    'the retry affordance dispatches RetryProcessingStatus, which clears the '
    'unavailable flag - proving the real wire, not just the enum value',
    (tester) async {
      final harness = _build(
        processingFeedStatus: ProcessingFeedStatus.unavailable,
      );
      try {
        await tester.pumpWidget(_host(harness: harness));
        await tester.pump();

        // Connected AND linked, so the resolver reaches the `unavailable`
        // rung rather than being pre-empted by `disconnected`/`notLinked`.
        harness.geniusApi.emitConnection(
          SGNUSConnection(
            sgnusAddress: _linkedWallet.address,
            walletAddress: _linkedWallet.address,
            isConnected: true,
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(find.text('Status unavailable'), findsOneWidget);
        expect(find.text('Reconnect ›'), findsOneWidget);
        expect(
          harness.appBloc.state.processingFeedStatus,
          ProcessingFeedStatus.unavailable,
        );

        await tester.tap(find.text('Reconnect ›'));
        await tester.pump();
        await tester.pump();

        expect(
          harness.appBloc.state.processingFeedStatus,
          ProcessingFeedStatus.neverTicked,
        );
      } finally {
        await _teardown(tester, harness);
      }
    },
  );
}
