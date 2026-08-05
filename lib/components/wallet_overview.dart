import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/account.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_wallet/account/account_drawer.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/compute/compute_panel.dart';
import 'package:genius_wallet/dashboard/compute/compute_state.dart';
import 'package:genius_wallet/dashboard/gnus/cubit/gnus_cubit.dart';
import 'package:genius_wallet/services/coins_service.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_cubit.dart';
import 'package:genius_wallet/submit_job/view/job_drawer.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

/// The dashboard's first card - the compute panel host (`14-08-PLAN.md`).
///
/// **This subtree is the OWNER of the job cubit** ([SubmitJobCubit]): it is
/// created here, in [WalletsOverviewState.initState], and disposed here, in
/// [WalletsOverviewState.dispose]. Not inside the drawer -
/// `lib/submit_job/view/job_drawer.dart`'s own doc comment names this file
/// as the other half of that arrangement, precisely so that a barrier tap
/// on the drawer during the in-flight step cannot destroy an in-flight
/// job's hash, which would make it unrecoverable - the exact bug this phase
/// exists to close (`T-14-31`).
class WalletsOverview extends StatefulWidget {
  final Account? account;
  final GeniusApi geniusApi;
  const WalletsOverview({
    super.key,
    required this.geniusApi,
    required this.account,
  });
  @override
  WalletsOverviewState createState() => WalletsOverviewState();
}

class WalletsOverviewState extends State<WalletsOverview> {
  bool _useMinions = false;
  double _gnusBalance = 0;
  double _minionsBalance = 0;
  Timer? _balanceTimer;

  // This subtree owns both cubits the job flow needs. GnusCubit has no
  // provider anywhere above the dashboard - router.dart:327 constructs its
  // own per `/submit_job` route - so one is built here too, mirroring the
  // router's own construction exactly rather than reaching for a provider
  // that does not exist at this point in the tree.
  late final GnusCubit _gnusCubit;
  late final SubmitJobCubit _submitJobCubit;

  @override
  void initState() {
    super.initState();
    final walletDetailsCubit = context.read<WalletDetailsCubit>();
    _gnusCubit = GnusCubit(CoinService(), walletDetailsCubit);
    _submitJobCubit = SubmitJobCubit(
      walletDetailsCubit: walletDetailsCubit,
      gnusCubit: _gnusCubit,
      geniusApi: widget.geniusApi,
    );
    _fetchBalances();
    // 10s matches the deleted `genius_balance_display.dart:58-61`'s own
    // polling cadence for these same two SDK reads - this card replaces
    // that widget's use here (`14-08-PLAN.md` Task 3), so it mirrors the
    // same interval rather than inventing a new one. This tick doubles as
    // what lets `ComputeState.jobComplete` decay to `ready` after its 60s
    // window: `AppBloc` only re-emits on a genuine field change, so once
    // the processing feed goes quiet nothing else would force a rebuild
    // that re-reads `DateTime.now()`.
    _balanceTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _fetchBalances(),
    );
  }

  void _fetchBalances() {
    final gnus = double.tryParse(widget.geniusApi.getSGNUSBalance()) ?? 0;
    final minions = double.tryParse(widget.geniusApi.getMinionsBalance()) ?? 0;
    if (mounted) {
      setState(() {
        _gnusBalance = gnus;
        _minionsBalance = minions;
      });
    }
  }

  /// Sets the unit rather than flipping it (`260731-kc5-PLAN.md`'s
  /// state-shape decision). The early return is not decoration - it is what
  /// makes a tap on the already-active segment cost nothing, no rebuild and
  /// no flip, rather than relying on the call site to guard it.
  void _setUnit(bool useMinions) {
    if (useMinions == _useMinions) {
      return;
    }
    setState(() => _useMinions = useMinions);
  }

  void _handleLinkTap(BuildContext context, ComputeLink link) {
    switch (link) {
      case ComputeLink.none:
        break;
      case ComputeLink.chooseWallet:
      case ComputeLink.switchWallet:
        // Ignores its result (`14-08-PLAN.md` Task 1) - the drawer's own
        // `selectWallet()`/Hive write already made the choice durable; this
        // card only needs the rebuild that follows from `WalletDetailsCubit`
        // re-emitting, which the `BlocBuilder` below already subscribes to.
        unawaited(AccountDrawer.show(context));
      case ComputeLink.seeNodeStatus:
        unawaited(context.push('/network'));
      case ComputeLink.reconnect:
        // Re-arms `_processingTimer`, which `app_bloc.dart:192-195`
        // cancels permanently on a throw - this is what makes state 08's
        // fix real to a user, not just present in `AppState`. The link's
        // OWN label is `Reconnect ›` (14-09-PLAN.md Task 1c); the bloc
        // event stays named `RetryProcessingStatus` on purpose - the user
        // reads the link, the bloc does the retry, and re-arming a
        // cancelled timer genuinely is a retry regardless of what the
        // link is called.
        context.read<AppBloc>().add(RetryProcessingStatus());
    }
  }

  @override
  void dispose() {
    _balanceTimer?.cancel();
    // This subtree is the owner of both - see the class doc comment. Order
    // does not matter between these two; neither's close() depends on the
    // other still being open.
    _submitJobCubit.close();
    _gnusCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // WHY this exists (05-08, gap B1; re-justified by 14-08 Task 2): this
    // widget is mounted in a slot capped at `kDashboardPanelSlotHeight`
    // (`dashboard_screen.dart`), which is **340 since 2026-07-31** - raised
    // from 300 so the panel could adopt `GWSectionTitle` and put Balance on
    // the same baseline as the first Assets coin. That leaves 314px usable
    // once `DashboardScrollContainer`'s own border fold-in is counted
    // (`test/dashboard/compute_panel_height_test.dart` derives the budget
    // from the same constant rather than repeating a number, which is what
    // stops these two from drifting apart again).
    //
    // This is NO LONGER a workaround for content that overflows - it is a
    // text-scale net. It costs nothing while the content fits (the gesture
    // arena is untouched at zero scroll extent, same argument as before)
    // and it is what stops a device with an enlarged text scale from
    // striping the card, since every `Text` in the panel is measured at a
    // single line at scale 1.0 but would still need somewhere to go at a
    // larger one.
    //
    // Nested-scrollable interaction, checked and load-bearing - do not
    // "fix" this later: the outer `RefreshIndicator` in
    // `OneColumnDashBoardView` is unaffected while this content fits,
    // because a `Scrollable` whose min and max scroll extents are equal
    // installs no drag recognizer and never enters the gesture arena. When
    // the content does not fit (an enlarged text scale), the inner view
    // scrolls - which is the intended behavior in the only state where the
    // two differ.
    //
    // KNOWN RISK: `LayoutBuilder` throws if an ancestor queries intrinsic
    // dimensions of its subtree. None of the three call sites above do -
    // each reaches this widget through a flex row and a plain
    // `Container`/`Padding`, with no `IntrinsicHeight` anywhere in the
    // chain.
    return LayoutBuilder(
      builder: (context, constraints) {
        final double minHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 0.0;
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: BlocBuilder<AppBloc, AppState>(
              builder: (context, appState) {
                return BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
                  builder: (context, walletState) {
                    return StreamBuilder<SGNUSConnection>(
                      // Consumed directly, as this file already did before
                      // this plan - it is the reason the disconnected state
                      // needs no connectivity dependency: `SGNUSConnection`
                      // carries `isConnected` itself
                      // (`packages/genius_api/lib/models/sgnus_connection.dart:11`).
                      stream: widget.geniusApi.getSGNUSConnectionStream(),
                      builder: (context, snapshot) {
                        final connection = snapshot.data;
                        final selectedWallet = walletState.selectedWallet;

                        final sinceJobFinished =
                            appState.processingCompletedAt == null
                            ? null
                            : DateTime.now().difference(
                                appState.processingCompletedAt!,
                              );

                        final computeState = resolveComputeState(
                          hasSelectedWallet: selectedWallet != null,
                          isNodeConnected: connection?.isConnected ?? false,
                          nodeWalletAddress: connection?.walletAddress ?? '',
                          selectedWalletAddress: selectedWallet?.address ?? '',
                          isProcessingUnavailable:
                              appState.processingFeedStatus ==
                              ProcessingFeedStatus.unavailable,
                          initPercentage: appState.initPercentage,
                          isProcessing: appState.isProcessing,
                          sinceJobFinished: sinceJobFinished,
                        );

                        final view = viewForComputeState(
                          computeState,
                          initPercentage: appState.initPercentage,
                          processingPercentage: appState.processingPercentage,
                        );

                        final balance = _useMinions
                            ? _minionsBalance
                            : _gnusBalance;

                        return ComputePanel(
                          view: view,
                          balance: balance,
                          // No live GNUS/USD price feed is reachable from
                          // this dashboard today (`genius_api`'s `Coin`
                          // model carries no price field; the CoinGecko
                          // market-data path is a real HTTP call that must
                          // not run unguarded from a widget's `initState` -
                          // `flutter test` has no network and a call left
                          // pending past a test's end is exactly the kind
                          // of hang `test/account/account_drawer_show_test.dart`'s
                          // header extensively documents for real I/O
                          // inside `testWidgets`). `showBalanceFiatSubline`
                          // still gates correctly; this only means the
                          // mitigation line for the GNUS/USD unit clash
                          // (`14-CONTEXT.md`) is empty for now - no bug
                          // this plan closes depends on it. See SUMMARY's
                          // Known Stubs.
                          fiatSubline: '',
                          useMinions: _useMinions,
                          onUnitChanged: _setUnit,
                          onLinkTap: (link) => _handleLinkTap(context, link),
                          onNewJob: () => unawaited(
                            JobDrawer.show(context, cubit: _submitJobCubit),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
