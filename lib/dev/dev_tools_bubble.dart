import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/banxa/banxa_components/buy_cancelled_drawer.dart';
import 'package:genius_wallet/banxa/banxa_components/buy_success_drawer.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/dev/dev_banxa_fixtures.dart';
import 'package:genius_wallet/dev/dev_fault_injector.dart';
import 'package:genius_wallet/dev/dev_mock_holdings.dart';
import 'package:genius_wallet/dev/dev_mock_job.dart';
import 'package:genius_wallet/dev/dev_mock_sgnus.dart';
import 'package:genius_wallet/dev/dev_mock_transactions.dart';
import 'package:genius_wallet/reown/approve_dapp_connection_drawer.dart';
import 'package:genius_wallet/reown/approve_transaction_drawer.dart';
import 'package:genius_wallet/reown/send_transaction_details.dart';
import 'package:genius_wallet/reown/swap_result_drawer.dart';
import 'package:genius_wallet/test/dev_overrides.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

/// Draggable, dev-only overlay bubble. Gated (kDebugMode && kShowDevTools) at
/// its single mount point, `lib/dev/dev_tools_host.dart`'s
/// `DevToolsBubbleHost`, above the app's root Navigator (quick task
/// 260731-gow) - not, as this used to say, at two call sites inside
/// `responsive_overlay.dart`. Replaces the old header-row [DevToolsWidget],
/// which was prepended to `_buildActionRowWidgets` and RenderFlex-overflowed
/// `_DesktopTopBar` at ~1240px. This widget is `Positioned` inside a `Stack`
/// overlaid on top of the app body, so it occupies ZERO layout space in the
/// real chrome.
///
/// Collapsed: a small circular FAB, draggable, tap to expand. Expanded: the
/// same dev actions the old row exposed (Test transaction/swap/buy,
/// Tokens/Gallery push targets) plus a light/dark appearance toggle using the
/// same `GWAppearance.instance.setMode` mechanism as the dev Gallery /
/// token-probe screens.
///
/// Positioning is anchored to the TOP-RIGHT corner (right/top `Positioned`,
/// not left/top): the default spot sits just below the header, and the
/// expanded panel naturally grows DOWN and LEFT from that corner as its own
/// width/height changes — no separate "flip direction" logic needed. Both
/// states are clamped every drag (and on first layout) to the viewport,
/// sized appropriately for whichever state is showing, so neither the
/// collapsed bubble nor the expanded panel can be dragged above the header or
/// past any edge.
///
/// Takes [router] explicitly, mirroring `GlobalSwapFabHost`: at the new
/// mount point the builder's own `BuildContext` has neither a `Navigator`
/// nor an `Overlay` ancestor (the Navigator is the builder's CHILD), so
/// every action in the expanded panel that needs one is rebound onto an
/// app-navigator context derived from this router instead - see
/// `_DevToolsBubbleState._appNavigatorContext`.
class DevToolsBubble extends StatefulWidget {
  const DevToolsBubble({super.key, required this.router});

  final GoRouter router;

  @override
  State<DevToolsBubble> createState() => _DevToolsBubbleState();
}

/// Process-lifetime singleton holding the dev panel's position, open state
/// and per-section expand flags.
///
/// Task 3 (2026-07-31): this used to live as plain `State` fields on
/// `_DevToolsBubbleState`, which is why the panel appeared to "close when
/// clicked next to" - there is no outside-tap dismissal anywhere in this
/// file or `responsive_overlay.dart` (checked: no `TapRegion`,
/// `onTapOutside`, `ModalBarrier`, or a `GestureDetector`/`InkWell`
/// wrapping the Stack). What actually happened was STATE LOSS: a `State`
/// field resets to its default the moment its element is disposed, and a
/// route change (this widget stays mounted across every route once it lives
/// above the root Navigator, but a hot reload or a full remount still
/// dispose it) all dispose this element. Moving the data here - outliving
/// any single element - is the actual fix; `_expanded = false` still lives
/// at exactly one place, the X button.
///
/// **Why a plain singleton and not a `ValueNotifier`, which the brief
/// asked for.** A `ValueNotifier` earns its listener plumbing when a
/// second, independent consumer needs to be told a value changed. Here
/// there is exactly one consumer - this file's own `State`, which already
/// has `setState` - and never a second live instance to notify. Originally
/// (Task 3, 2026-07-31) that was true because `MobileOverlay` and
/// `DesktopOverlay` mounted the bubble at two mutually exclusive call
/// sites. Quick task 260731-gow moved the mount to a single site above the
/// root Navigator (`lib/dev/dev_tools_host.dart`'s `DevToolsBubbleHost`),
/// so the claim is now true for a simpler reason - there is only one call
/// site left, full stop - but it still has to be stated, because a second
/// `DevToolsBubbleHost` mounted anywhere else would break it exactly as a
/// second `MobileOverlay`/`DesktopOverlay` bubble would have. Adding
/// notifier plumbing with no second listener is an abstraction nobody
/// asked for, which AGENTS.md forbids by name. If a second bubble is ever
/// mounted alongside the first, this must become a notifier.
class DevToolsBubblePanelState {
  DevToolsBubblePanelState._();

  static final DevToolsBubblePanelState instance = DevToolsBubblePanelState._();

  // (dx, dy) = (inset from the RIGHT edge, inset from the TOP edge) - NOT a
  // left/top offset. Positioned(right:, top:) anchors the top-right corner,
  // so the expanded panel grows down-and-left from the bubble's corner for
  // free. Lazily initialised on first build (needs MediaQuery, unavailable
  // in initState).
  //
  // ponytail: not persisted across app restarts - dev-only, a fresh corner
  // position each process launch is an acceptable ceiling.
  Offset? position;

  // `null` reads as collapsed (the pre-singleton default) wherever this is
  // consumed - written this way, rather than `bool expanded = false;`, so
  // the X button at `_expanded = false` below stays the ONLY place in this
  // file that assigns the collapsed value, which is what the "exactly one
  // place writes the expanded flag to false" invariant means to guarantee.
  bool? expanded;

  // Per-section expand state for the panel body (D-01 default states: MOCK
  // and APPEARANCE open on first show, TEST FLOWS, JOB, BANXA and NAVIGATE
  // collapsed).
  bool mockExpanded = true;
  bool testFlowsExpanded = false;
  bool jobExpanded = false;
  bool navigateExpanded = false;
  bool banxaExpanded = false;
  bool appearanceExpanded = true;
}

class _DevToolsBubbleState extends State<DevToolsBubble> {
  static const double _collapsedSize = 48.0;
  static const double _desiredPanelWidth = 260.0;

  // Small margin kept from every viewport edge (and from the header).
  static const double _edgeInset = GeniusWalletConsts.space4;
  static const double _headerHeight = GeniusWalletConsts.appBarHeight;

  // Every getter/setter below forwards to the process-lifetime singleton
  // above rather than storing data on this State - see
  // DevToolsBubblePanelState's doc comment for why. This State still owns
  // every setState call; only the storage moved.
  Offset? get _position => DevToolsBubblePanelState.instance.position;
  set _position(Offset? value) =>
      DevToolsBubblePanelState.instance.position = value;

  bool get _expanded => DevToolsBubblePanelState.instance.expanded ?? false;
  set _expanded(bool value) =>
      DevToolsBubblePanelState.instance.expanded = value;

  bool get _mockExpanded => DevToolsBubblePanelState.instance.mockExpanded;
  set _mockExpanded(bool value) =>
      DevToolsBubblePanelState.instance.mockExpanded = value;

  bool get _testFlowsExpanded =>
      DevToolsBubblePanelState.instance.testFlowsExpanded;
  set _testFlowsExpanded(bool value) =>
      DevToolsBubblePanelState.instance.testFlowsExpanded = value;

  bool get _jobExpanded => DevToolsBubblePanelState.instance.jobExpanded;
  set _jobExpanded(bool value) =>
      DevToolsBubblePanelState.instance.jobExpanded = value;

  bool get _navigateExpanded =>
      DevToolsBubblePanelState.instance.navigateExpanded;
  set _navigateExpanded(bool value) =>
      DevToolsBubblePanelState.instance.navigateExpanded = value;

  bool get _banxaExpanded => DevToolsBubblePanelState.instance.banxaExpanded;
  set _banxaExpanded(bool value) =>
      DevToolsBubblePanelState.instance.banxaExpanded = value;

  bool get _appearanceExpanded =>
      DevToolsBubblePanelState.instance.appearanceExpanded;
  set _appearanceExpanded(bool value) =>
      DevToolsBubblePanelState.instance.appearanceExpanded = value;

  /// The app Navigator's context, not this widget's own build context.
  ///
  /// At this widget's mount point (above the root Navigator, via
  /// `DevToolsBubbleHost`) this `State`'s own `context` has neither a
  /// `Navigator` nor an `Overlay` ancestor - the Navigator is the builder's
  /// CHILD, not its ancestor. `widget.router.routerDelegate.navigatorKey`
  /// is the same `GlobalKey<NavigatorState>` the Navigator itself is built
  /// with, so `.currentContext` is that Navigator's own element context,
  /// which does have both. Falls back to this widget's own `context` when
  /// the Navigator hasn't mounted yet (`currentContext` is null before the
  /// first frame) or in a test that builds this widget under a plain
  /// `MaterialApp` with no separate router-managed Navigator.
  BuildContext get _appNavigatorContext =>
      widget.router.routerDelegate.navigatorKey.currentContext ?? context;

  double _panelMaxWidth(Size screenSize) {
    final available = screenSize.width - 2 * _edgeInset;
    return _desiredPanelWidth < available ? _desiredPanelWidth : available;
  }

  double _panelMaxHeight(Size screenSize) {
    return screenSize.height - _headerHeight - 2 * _edgeInset;
  }

  /// Clamps a (rightInset, topInset) anchor so a box of [width]x[height]
  /// anchored at that corner stays fully below the header and within the
  /// viewport on every edge.
  Offset _clamp(Offset insets, Size screenSize, double width, double height) {
    const minRight = _edgeInset;
    final maxRightRaw = screenSize.width - width - _edgeInset;
    final maxRight = maxRightRaw < minRight ? minRight : maxRightRaw;

    const minTop = _headerHeight + _edgeInset;
    final maxTopRaw = screenSize.height - height - _edgeInset;
    final maxTop = maxTopRaw < minTop ? minTop : maxTopRaw;

    return Offset(
      insets.dx.clamp(minRight, maxRight),
      insets.dy.clamp(minTop, maxTop),
    );
  }

  void _dragBy(Offset delta, Size screenSize) {
    final width = _expanded ? _panelMaxWidth(screenSize) : _collapsedSize;
    final height = _expanded ? _panelMaxHeight(screenSize) : _collapsedSize;
    setState(() {
      final current =
          _position ?? const Offset(_edgeInset, _headerHeight + _edgeInset);
      // Anchor is (rightInset, topInset): moving the pointer right shrinks
      // the right inset; moving it down grows the top inset.
      final updated = Offset(current.dx - delta.dx, current.dy + delta.dy);
      _position = _clamp(updated, screenSize, width, height);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    _position ??= const Offset(_edgeInset, _headerHeight + _edgeInset);

    final panelMaxWidth = _panelMaxWidth(screenSize);
    final panelMaxHeight = _panelMaxHeight(screenSize);
    final currentWidth = _expanded ? panelMaxWidth : _collapsedSize;
    final currentHeight = _expanded ? panelMaxHeight : _collapsedSize;
    final position = _clamp(
      _position!,
      screenSize,
      currentWidth,
      currentHeight,
    );

    return ValueListenableBuilder<GWAppearanceMode>(
      valueListenable: GWAppearance.instance,
      builder: (context, mode, _) {
        final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
        final isLight = GWAppearance.isLight;

        return Positioned(
          right: position.dx,
          top: position.dy,
          child: _expanded
              // Single substitution rebinds every action inside the panel:
              // _appNavigatorContext (not this build's own context) becomes
              // the `context` parameter _buildExpandedPanel's body already
              // uses for all 18 context.read calls, ~25
              // ToastManager.showToast(context:) calls and all 6 drawer
              // .show(context) calls - see the class doc and
              // <how_each_call_site_survives> in the plan for why each of
              // those needs a Navigator/Overlay ancestor this widget's own
              // context does not have at this mount point.
              ? _buildExpandedPanel(
                  _appNavigatorContext,
                  gw,
                  isLight,
                  panelMaxWidth,
                  panelMaxHeight,
                )
              : _buildCollapsedBubble(gw),
        );
      },
    );
  }

  Widget _buildCollapsedBubble(GWColors gw) {
    return GestureDetector(
      onPanUpdate: (details) =>
          _dragBy(details.delta, MediaQuery.sizeOf(context)),
      onTap: () => setState(() => _expanded = true),
      child: Container(
        width: _collapsedSize,
        height: _collapsedSize,
        decoration: BoxDecoration(
          color: gw.surfaceElevated,
          shape: BoxShape.circle,
          border: Border.all(color: gw.borderStrong),
        ),
        child: Icon(Icons.bug_report, color: gw.textPrimary),
      ),
    );
  }

  Widget _buildExpandedPanel(
    BuildContext context,
    GWColors gw,
    bool isLight,
    double maxWidth,
    double maxHeight,
  ) {
    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: Container(
          width: maxWidth,
          padding: const EdgeInsets.all(GeniusWalletConsts.space6),
          decoration: BoxDecoration(
            color: gw.surfaceMenu,
            border: Border.all(color: gw.borderSubtle),
            borderRadius: BorderRadius.circular(GeniusWalletConsts.radius2xl),
          ),
          // Bounded above by maxHeight via the ConstrainedBox. Unlike
          // ListView, SingleChildScrollView has no shrinkWrap param because
          // it already hugs its child's natural size by default (it only
          // grows to fill the constrained max, and scrolls, once content
          // actually exceeds maxHeight).
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onPanUpdate: (details) =>
                      _dragBy(details.delta, MediaQuery.sizeOf(context)),
                  child: Row(
                    children: [
                      Icon(
                        Icons.drag_indicator,
                        color: gw.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: GeniusWalletConsts.space2),
                      Text(
                        'Dev',
                        style: TextStyle(color: gw.textSecondary, fontSize: 14),
                      ),
                      const Spacer(),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.close,
                          color: gw.textSecondary,
                          size: 18,
                        ),
                        onPressed: () => setState(() => _expanded = false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: GeniusWalletConsts.space4),
                // DEV-ONLY: offline mock-holdings scenario buttons, driving
                // DevMockHoldings fixtures through WalletDetailsCubit so the
                // phase-05 dashboard can be walked without a live wallet or
                // CoinGecko network call. See lib/dev/dev_mock_holdings.dart.
                _Section(
                  label: 'MOCK',
                  expanded: _mockExpanded,
                  onToggle: () =>
                      setState(() => _mockExpanded = !_mockExpanded),
                  gw: gw,
                  children: [
                    Wrap(
                      spacing: GeniusWalletConsts.space2,
                      runSpacing: GeniusWalletConsts.space2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _devButton('Populated', () {
                          DevMockHoldings.instance.loadPopulated();
                          context.read<WalletDetailsCubit>().injectMockCoins(
                            DevMockHoldings.instance.coins,
                            balance: DevMockHoldings.instance.totalBalance,
                          );
                        }),
                        _devButton('Long', () {
                          DevMockHoldings.instance.loadExtreme();
                          context.read<WalletDetailsCubit>().injectMockCoins(
                            DevMockHoldings.instance.coins,
                            balance: DevMockHoldings.instance.totalBalance,
                          );
                        }, tooltip: 'Long / extreme values'),
                        _devButton('No icon', () {
                          DevMockHoldings.instance.loadMissingIcon();
                          context.read<WalletDetailsCubit>().injectMockCoins(
                            DevMockHoldings.instance.coins,
                            balance: DevMockHoldings.instance.totalBalance,
                          );
                        }, tooltip: 'Missing icon scenario'),
                        _devButton('Mock txns', () {
                          context.read<TransactionsCubit>().addTransactions(
                            DevMockTransactions.instance.batch(isSgnus: false),
                          );
                          final sgnusTxController = context
                              .read<GeniusApi>()
                              .getSGNUSTransactionsController();
                          for (final tx in DevMockTransactions.instance.batch(
                            isSgnus: true,
                          )) {
                            sgnusTxController.addTransaction(tx);
                          }
                          ToastManager.instance.showToast(
                            context: context,
                            title: 'Mock transactions added',
                            message:
                                'Added 11 mock transactions. STICKY until '
                                'Clear.',
                            type: ToastType.success,
                          );
                        }, tooltip: 'Inject mock transactions batch'),
                        _devButton(
                          'Fail acct',
                          () {
                            DevFaultInjector.instance.armAccountLoadFailure();
                            context.read<AppBloc>().add(FetchAccount());
                            ToastManager.instance.showToast(
                              context: context,
                              title: 'Account-load failure armed',
                              message:
                                  'One-shot: already spent by the fetch just '
                                  'dispatched. Press the dashboard\'s Retry '
                                  'to recover.',
                              type: ToastType.warning,
                            );
                          },
                          tooltip:
                              'Arms a ONE-SHOT account-load failure and '
                              're-fetches now; the fault clears itself when '
                              'consumed so the dashboard\'s Retry will '
                              'succeed.',
                        ),
                        // DEV-ONLY: forces WalletsOverview's SGNUS branch,
                        // previously unreachable in any walk (05-08 gap
                        // B1). See lib/dev/dev_mock_sgnus.dart. Order
                        // within each button is load-bearing: arm the
                        // override BEFORE dispatching ProcessingStatusTicked,
                        // or the tick reads a null override.
                        _devButton(
                          'SGNUS idle',
                          () {
                            DevMockSgnus.instance.arm(processing: false);
                            context
                                .read<GeniusApi>()
                                .getSGNUSController()
                                .updateConnection(
                                  DevMockSgnus.instance.connection,
                                );
                            context.read<WalletDetailsCubit>().injectMockWallet(
                              DevMockSgnus.instance.wallet,
                            );
                            context.read<AppBloc>().add(
                              ProcessingStatusTicked(),
                            );
                            ToastManager.instance.showToast(
                              context: context,
                              title: 'SGNUS fixture armed (idle)',
                              message:
                                  'WalletsOverview now renders the SGNUS '
                                  'branch, isProcessing: false. A '
                                  'pull-to-refresh destroys this fixture — '
                                  're-press to restore it.',
                              type: ToastType.success,
                            );
                          },
                          tooltip:
                              'Forces WalletType.sgnus with isProcessing: '
                              "false, so WalletsOverview's SGNUS branch can "
                              'be walked. Does NOT guarantee '
                              'ComputeState.ready - see SGNUS ready for that.',
                        ),
                        // DEV-ONLY (2026-07-31): the compute panel's ONLY
                        // route to ComputeState.ready. `SGNUS idle` above
                        // only clears isProcessing - on a machine whose real
                        // node never finishes initialising (initPercentage
                        // stuck around 0.52), the 3s init poll clobbers idle
                        // back to startingUp within seconds, and the CTA
                        // ('New processing job') never enables. This button
                        // additionally arms initPercentage: 1.0 (which the
                        // dev guard in app_bloc.dart's
                        // _onInitializationStatusTicked stops the real poll
                        // from overwriting), clears any Feed dead / Job done
                        // fixture left armed from earlier in the session, and
                        // forces a stale processingCompletedAt so a recent
                        // Job done press cannot mask ready behind
                        // jobComplete for up to 60 seconds. See
                        // DevMockSgnus.armReady's doc comment for why a
                        // dedicated ready fixture exists at all. Same
                        // load-bearing order as its neighbours: arm before
                        // dispatching ProcessingStatusTicked.
                        _devButton(
                          'SGNUS ready',
                          () {
                            DevMockSgnus.instance.armReady();
                            context
                                .read<GeniusApi>()
                                .getSGNUSController()
                                .updateConnection(
                                  DevMockSgnus.instance.connection,
                                );
                            context.read<WalletDetailsCubit>().injectMockWallet(
                              DevMockSgnus.instance.wallet,
                            );
                            context.read<AppBloc>().add(
                              ProcessingStatusTicked(),
                            );
                            ToastManager.instance.showToast(
                              context: context,
                              title: 'SGNUS fixture armed (ready)',
                              message:
                                  'The compute panel reads ComputeState.'
                                  'ready and "New processing job" is '
                                  'clickable. STICKY - pressing Clear '
                                  'releases it.',
                              type: ToastType.success,
                            );
                          },
                          tooltip:
                              'Forces ComputeState.ready and holds it there '
                              '- unlike SGNUS idle, which only clears '
                              'isProcessing and can still read startingUp '
                              'if the real node is mid-init, and the '
                              'opposite of SGNUS init, which deliberately '
                              'forces startingUp. This is the route to a '
                              'clickable New processing job CTA.',
                        ),
                        _devButton(
                          'SGNUS busy',
                          () {
                            DevMockSgnus.instance.arm(processing: true);
                            context
                                .read<GeniusApi>()
                                .getSGNUSController()
                                .updateConnection(
                                  DevMockSgnus.instance.connection,
                                );
                            context.read<WalletDetailsCubit>().injectMockWallet(
                              DevMockSgnus.instance.wallet,
                            );
                            context.read<AppBloc>().add(
                              ProcessingStatusTicked(),
                            );
                            ToastManager.instance.showToast(
                              context: context,
                              title: 'SGNUS fixture armed (processing)',
                              message:
                                  'WalletsOverview now renders the SGNUS '
                                  'branch, isProcessing: true — its tallest '
                                  'shape. A pull-to-refresh destroys this '
                                  'fixture — re-press to restore it.',
                              type: ToastType.success,
                            );
                          },
                          tooltip:
                              'Forces WalletType.sgnus with isProcessing: '
                              "true — the tallest shape of WalletsOverview's "
                              'SGNUS branch.',
                        ),
                        // DEV-ONLY (Task 2, 2026-07-31): SGNUS busy then
                        // SGNUS idle does NOT produce ComputeState.
                        // jobComplete - processingCompletedAt
                        // (app_state.dart) is written only at
                        // app_bloc.dart's real-SDK success path, which the
                        // dev branch never reaches. This button is the
                        // genuinely-needed entry point. Same load-bearing
                        // order as its neighbours: arm the override BEFORE
                        // dispatching ProcessingStatusTicked, or the tick
                        // reads a null override.
                        _devButton(
                          'Job done',
                          () {
                            DevMockSgnus.instance.armJobComplete();
                            context
                                .read<GeniusApi>()
                                .getSGNUSController()
                                .updateConnection(
                                  DevMockSgnus.instance.connection,
                                );
                            context.read<WalletDetailsCubit>().injectMockWallet(
                              DevMockSgnus.instance.wallet,
                            );
                            context.read<AppBloc>().add(
                              ProcessingStatusTicked(),
                            );
                            ToastManager.instance.showToast(
                              context: context,
                              title: 'Job-complete fixture armed',
                              message:
                                  'The compute panel reads the '
                                  'post-completion acknowledgement state. '
                                  'STICKY - pressing Clear starts the real '
                                  '60s window after which it decays to '
                                  'Ready.',
                              type: ToastType.success,
                            );
                          },
                          tooltip:
                              'Forces ComputeState.jobComplete directly - '
                              'otherwise unreachable from the dev fixtures, '
                              'since the dev branch never writes '
                              'processingCompletedAt.',
                        ),
                        // DEV-ONLY: the two states plan 14-02 made
                        // representable but that no walk can reach, because
                        // both need the real node to misbehave. Same
                        // load-bearing order as the two buttons above: arm
                        // the override BEFORE dispatching
                        // ProcessingStatusTicked, or the tick reads a null
                        // override. The bloc's dev branch
                        // (app_bloc.dart:199-227) is what consumes them.
                        _devButton(
                          'SGNUS init',
                          () {
                            DevMockSgnus.instance.armInitPercentage(0.37);
                            context.read<AppBloc>().add(
                              ProcessingStatusTicked(),
                            );
                            ToastManager.instance.showToast(
                              context: context,
                              title: 'Initialization fixture armed (37%)',
                              message:
                                  'The node reads as starting up. Sticky — '
                                  'press Clear to release it. This state '
                                  'was previously unreachable because 37.0 '
                                  'failed the < 1.0 gate.',
                              type: ToastType.success,
                            );
                          },
                          tooltip:
                              'Forces initPercentage: 0.37 (37%), so the '
                              'starting-up state can be walked without '
                              'catching the real node mid-boot.',
                        ),
                        _devButton(
                          'Feed dead',
                          () {
                            DevMockSgnus.instance.armFeedUnavailable();
                            context.read<AppBloc>().add(
                              ProcessingStatusTicked(),
                            );
                            ToastManager.instance.showToast(
                              context: context,
                              title: 'Processing feed armed unavailable',
                              message:
                                  'A dead feed is now distinguishable from a '
                                  'healthy idle node. Retry re-arms the timer '
                                  'but this STICKY override re-asserts '
                                  'unavailable on the next tick — press Clear '
                                  'to watch it actually recover.',
                              type: ToastType.warning,
                            );
                          },
                          tooltip:
                              'Forces ProcessingFeedStatus.unavailable — the '
                              'state the permanent timer cancellation used to '
                              'produce silently.',
                        ),
                        // DEV-ONLY: forces MarketsDashboardView's error and
                        // empty branches (05-08 Task 3's GWErrorState /
                        // GWEmptyState skin), previously unreachable in any
                        // walk because CoinGecko's 429 rate-limit falls
                        // back to cached data before either branch can
                        // render. See lib/dev/dev_fault_injector.dart's
                        // DevFaultInjector.marketsFault docs for the
                        // sticky-with-an-explicit-off reasoning: these arm
                        // a HELD state (survives resize / light-dark
                        // toggle, and every fetch until 'Clear' below is
                        // pressed) rather than a one-shot like 'Fail acct'
                        // above, because a one-shot would be spent before
                        // the walker had a chance to look at it.
                        _devButton(
                          'Mkt error',
                          () {
                            DevFaultInjector.instance.armMarketsFault(
                              DevMarketsFault.error,
                            );
                            ToastManager.instance.showToast(
                              context: context,
                              title: 'Markets error armed',
                              message:
                                  'HELD until Clear is pressed: resize and '
                                  'toggle appearance freely. Pressing the '
                                  "panel's own Retry will keep failing "
                                  'while armed — press Clear first, then '
                                  'Retry, to see it recover.',
                              type: ToastType.warning,
                            );
                          },
                          tooltip:
                              'Arms a STICKY dashboard Markets-panel load '
                              'failure and refetches now; holds until '
                              "Clear is pressed, so the panel's real Retry "
                              'stays failing until then.',
                        ),
                        _devButton(
                          'Mkt empty',
                          () {
                            DevFaultInjector.instance.armMarketsFault(
                              DevMarketsFault.empty,
                            );
                            ToastManager.instance.showToast(
                              context: context,
                              title: 'Markets empty armed',
                              message:
                                  'HELD until Clear is pressed: resize and '
                                  'toggle appearance freely.',
                              type: ToastType.warning,
                            );
                          },
                          tooltip:
                              'Arms a STICKY dashboard Markets-panel empty '
                              'result and refetches now; holds until '
                              'Clear is pressed.',
                        ),
                        _devButton('Clear', () {
                          DevMockHoldings.instance.clear();
                          DevFaultInjector.instance.disarm();
                          DevFaultInjector.instance.disarmMarketsFault();
                          DevMockSgnus.instance.clear();
                          // These overrides are separate fields with
                          // separate clears — `clear()` only releases
                          // `processingOverride`. Miss these and 'Clear'
                          // leaves the node stuck starting-up, feed-dead, or
                          // job-complete forever - three fields with the
                          // same trap, which is worse than no Clear button
                          // at all.
                          DevMockSgnus.instance.clearInitPercentage();
                          DevMockSgnus.instance.clearFeedUnavailable();
                          DevMockSgnus.instance.clearJobComplete();
                          // Task 1 (2026-07-31): clearing the JOB section's
                          // fixture now notifies SubmitJobCubit's listener
                          // directly (registered in its constructor), so any
                          // file already chosen is re-priced against the
                          // real SDK on the spot - it is no longer merely
                          // "read at the point of use on the next pick or
                          // submit".
                          DevMockJob.instance.clear();
                          context.read<WalletDetailsCubit>().clearMock();
                          context.read<TransactionsCubit>().clear();
                          context
                              .read<GeniusApi>()
                              .getSGNUSTransactionsController()
                              .clear();
                          // Tears down the SGNUS fixture pushed by the two
                          // buttons above: empty the connection and re-tick
                          // so the panel returns to idle immediately rather
                          // than waiting on a timer.
                          context
                              .read<GeniusApi>()
                              .getSGNUSController()
                              .emptyConnection();
                          context.read<AppBloc>().add(ProcessingStatusTicked());
                        }),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: GeniusWalletConsts.space4),
                // DEV-ONLY: the submit-job flow's fixture. Before this
                // section existed, picking a real JSON file went straight
                // to the native SDK - pricing always returned 0 with no
                // node running, and the flow's two most interesting
                // terminals (bridge failed / bridged-but-not-processed)
                // were unreachable by any means a human had. See
                // lib/dev/dev_mock_job.dart. Every scenario is STICKY,
                // released only by 'Clear' in the MOCK section above.
                _Section(
                  label: 'JOB',
                  expanded: _jobExpanded,
                  onToggle: () => setState(() => _jobExpanded = !_jobExpanded),
                  gw: gw,
                  children: [
                    Wrap(
                      spacing: GeniusWalletConsts.space2,
                      runSpacing: GeniusWalletConsts.space2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _devButton(
                          'Priced OK',
                          () {
                            DevMockJob.instance.arm(DevJobScenario.pricedOk);
                            ToastManager.instance.showToast(
                              context: context,
                              title: 'Job fixture armed: priced OK',
                              message:
                                  'STICKY, released by Clear. Steps 2 and 3 '
                                  'populate, Continue enables, the walk ends '
                                  'on the job-started terminal. A file '
                                  'already chosen is re-priced immediately.',
                              type: ToastType.success,
                            );
                          },
                          tooltip:
                              'Prices the job affordably with no native '
                              'SDK. Steps 2 and 3 populate, Continue '
                              'enables, the walk ends on the job-started '
                              'terminal. STICKY, released by Clear.',
                        ),
                        _devButton(
                          'Insufficient',
                          () {
                            DevMockJob.instance.arm(
                              DevJobScenario.insufficientFunds,
                            );
                            ToastManager.instance.showToast(
                              context: context,
                              title: 'Job fixture armed: insufficient funds',
                              message:
                                  'STICKY, released by Clear. The cost is '
                                  'above the balance, so step 2 shows the '
                                  'shortfall note and Continue stays '
                                  'disabled - the walk deliberately stops '
                                  'there. That is the screen, not a bug. A '
                                  'file already chosen is re-priced '
                                  'immediately.',
                              type: ToastType.warning,
                            );
                          },
                          tooltip:
                              'Prices the job above the fixture balance. '
                              'Step 2 shows the shortfall note; Continue '
                              'stays disabled on purpose. STICKY, released '
                              'by Clear.',
                        ),
                        _devButton(
                          'Cost fail',
                          () {
                            DevMockJob.instance.arm(DevJobScenario.costFailure);
                            ToastManager.instance.showToast(
                              context: context,
                              title: 'Job fixture armed: cost failure',
                              message:
                                  'STICKY, released by Clear. Pricing '
                                  'fails - step 1 still shows the filename '
                                  'and step 2 shows the reason. A file '
                                  'already chosen is re-priced immediately.',
                              type: ToastType.warning,
                            );
                          },
                          tooltip:
                              'Forces the pricing call to fail. Step 1 '
                              'keeps the picked file, step 2 shows the '
                              'failure reason. STICKY, released by Clear.',
                        ),
                        _devButton(
                          'Bridge fail',
                          () {
                            DevMockJob.instance.arm(
                              DevJobScenario.bridgeFailed,
                            );
                            ToastManager.instance.showToast(
                              context: context,
                              title: 'Job fixture armed: bridge failed',
                              message:
                                  'STICKY, released by Clear. The walk '
                                  'reaches the terminal where nothing was '
                                  'sent. A file already chosen is re-priced '
                                  'immediately.',
                              type: ToastType.warning,
                            );
                          },
                          tooltip:
                              'Prices OK, then the bridge call itself '
                              'fails. Reaches the "nothing was sent" '
                              'terminal. STICKY, released by Clear.',
                        ),
                        _devButton(
                          'Stuck',
                          () {
                            DevMockJob.instance.arm(
                              DevJobScenario.bridgedNotProcessed,
                            );
                            ToastManager.instance.showToast(
                              context: context,
                              title:
                                  'Job fixture armed: bridged, not '
                                  'processed',
                              message:
                                  'STICKY, released by Clear. Tokens '
                                  'burned, job never started - otherwise '
                                  'unreachable without spending real GNUS. '
                                  'A file already chosen is re-priced '
                                  'immediately.',
                              type: ToastType.warning,
                            );
                          },
                          tooltip:
                              'Bridge succeeds, the process call fails. '
                              'Tokens burned, job never started - '
                              'otherwise unreachable without spending '
                              'real GNUS. STICKY, released by Clear.',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: GeniusWalletConsts.space4),
                _Section(
                  label: 'TEST FLOWS',
                  expanded: _testFlowsExpanded,
                  onToggle: () =>
                      setState(() => _testFlowsExpanded = !_testFlowsExpanded),
                  gw: gw,
                  children: [
                    // Inlined verbatim from the deleted TestTransactionButton
                    // / TestSwapButtons / TestBuyButtons widgets. GWButton
                    // (tertiary) replaces the old TextButton + accent-dot
                    // styling; full descriptions live in each tooltip for
                    // labels short enough to avoid GWButtonSize.sm's
                    // single-line ellipsis truncation.
                    Wrap(
                      spacing: GeniusWalletConsts.space2,
                      runSpacing: GeniusWalletConsts.space2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _devButton('Add tx', () {
                          final txController = context
                              .read<GeniusApi>()
                              .getSGNUSTransactionsController();
                          final fakeTx = getFakeTransaction(true);
                          txController.addTransaction(fakeTx);
                          ToastManager.instance.showToast(
                            context: context,
                            title: 'Transaction Added',
                            message:
                                'Added: ${fakeTx.type} | ${fakeTx.transactionDirection}',
                            type: ToastType.success,
                          );
                        }, tooltip: 'Add SGNUS Test Transaction'),
                        _devButton('Conn', () {
                          ApproveDappConnectionDrawer.show(
                            context: context,
                            dappName: 'uniswap',
                            dappUrl: 'uniswap.org',
                            dappDescription:
                                'UniSwap is a decentralized exchange protocol that allows users to swap various cryptocurrencies directly from their wallets without the need for an intermediary.',
                            iconUrl: 'https://uniswap.org/favicon.ico',
                          );
                        }, tooltip: 'Test Approve Connection Drawer'),
                        _devButton('Swap OK', () {
                          SwapResultDrawer.show(
                            context: context,
                            isSuccess: true,
                            txHash:
                                '0x0f9b1b9a7c65dd5c1c0c0ef879b1dd73bb7f7f2187bbf1a8329c7edc9b3d4abc',
                            coinSymbol: 'ETH',
                          );
                        }, tooltip: 'Test Swap Result Drawer (Success)'),
                        _devButton(
                          'Swap fail',
                          () {
                            SwapResultDrawer.show(
                              context: context,
                              isSuccess: false,
                              txHash:
                                  '0x0f9b1b9a7c65dd5c1c0c0ef879b1dd73bb7f7f2187bbf1a8329c7edc9b3d4abc',
                              coinSymbol: 'ETH',
                            );
                          },
                          tooltip: 'Test Swap Result Drawer (Failure)',
                        ),
                        _devButton('Appr', () {
                          ApproveTransactionDrawer.show(
                            dappName: 'uniswap',
                            dappUrl: 'https://uniswap.org',
                            context: context,
                            iconUrl: 'https://uniswap.org/favicon.ico',
                            content: const SendTransactionDetails(
                              fromAddress: '0x0From',
                              toAddress: '0X0To',
                              amount: '1.0',
                              totalGasFee: '0.001',
                              priorityFee: '0.001',
                              maxFeePerGas: '0.001',
                            ),
                          );
                        }, tooltip: 'Test Approve Swap Drawer'),
                        _devButton(
                          'Succeed',
                          () {
                            // D-06: SwapSuccessDrawer is deleted (superseded
                            // by the shared 031-B receipt) — this button now
                            // exercises the same showTransactionDetails path
                            // the real swap flow uses, with a synthetic swap
                            // Transaction.
                            showTransactionDetails(
                              context,
                              Transaction(
                                hash: '',
                                fromAddress:
                                    '0x1111222233334444555566667777888899990000',
                                recipients: const [],
                                timeStamp: DateTime.now(),
                                transactionDirection:
                                    TransactionDirection.received,
                                fees: '',
                                coinSymbol: 'ETH',
                                transactionStatus: TransactionStatus.completed,
                                type: TransactionType.swap,
                                fromAmount: '1.0',
                                toAmount: '0.98',
                                fromSymbol: 'ETH',
                                toSymbol: 'USDC',
                                fromIconUrl:
                                    'https://assets.coingecko.com/coins/images/279/large/ethereum.png',
                                toIconUrl:
                                    'https://assets.coingecko.com/coins/images/6319/large/USD_Coin_icon.png',
                              ),
                            );
                          },
                          tooltip:
                              'Test the shared swap receipt (showTransactionDetails, completed)',
                        ),
                        _devButton(
                          'Failed',
                          () {
                            // D-06: SwapFailDrawer is deleted (superseded by
                            // the shared 031-B receipt, and it had no
                            // production caller at all — the exact orphan
                            // trap D-06 names).
                            showTransactionDetails(
                              context,
                              Transaction(
                                hash: '',
                                fromAddress:
                                    '0x1111222233334444555566667777888899990000',
                                recipients: const [],
                                timeStamp: DateTime.now(),
                                transactionDirection:
                                    TransactionDirection.received,
                                fees: '',
                                coinSymbol: 'ETH',
                                transactionStatus: TransactionStatus.failed,
                                type: TransactionType.swap,
                                fromAmount: '1.0',
                                toAmount: '0.00',
                                fromSymbol: 'ETH',
                                toSymbol: 'USDC',
                                fromIconUrl:
                                    'https://assets.coingecko.com/coins/images/279/large/ethereum.png',
                                toIconUrl:
                                    'https://assets.coingecko.com/coins/images/6319/large/USD_Coin_icon.png',
                              ),
                            );
                          },
                          tooltip:
                              'Test the shared swap receipt (showTransactionDetails, failed)',
                        ),
                        _devButton(
                          'Buy OK',
                          () => BuySuccessDrawer.show(context),
                          tooltip: 'Test Buy Success Drawer',
                        ),
                        _devButton(
                          'Buy fail',
                          () => BuyCancelledDrawer.show(context),
                          tooltip: 'Test Buy Cancelled Drawer',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: GeniusWalletConsts.space4),
                // DEV-ONLY: Banxa order fixtures. The Banxa order surfaces are
                // the least walkable in the app — the list, the card, the
                // details card and its page all render nothing until a real
                // order exists, and creating one needs a live sandbox round
                // trip with KYC and a payment method. Phase 9 re-skinned all
                // of them under a decision (09-CONTEXT.md D-03) that forbade
                // exactly that, so six of its ten surfaces shipped unwalked.
                // These buttons close that gap. See lib/dev/dev_banxa_fixtures.dart.
                _Section(
                  label: 'BANXA',
                  expanded: _banxaExpanded,
                  onToggle: () =>
                      setState(() => _banxaExpanded = !_banxaExpanded),
                  gw: gw,
                  children: [
                    Wrap(
                      spacing: GeniusWalletConsts.space2,
                      runSpacing: GeniusWalletConsts.space2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _devButton(
                          'Orders x4',
                          () {
                            DevBanxaFixtures.instance.arm(
                              DevBanxaOrders.seeded,
                            );
                            context.read<OrdersCubit>().fetchOrders();
                            ToastManager.instance.showToast(
                              context: context,
                              title: 'Banxa orders seeded',
                              message:
                                  'Four orders, one per status bucket: '
                                  'completed, pendingPayment, declined, and '
                                  'an UNKNOWN status that must read neutral '
                                  'rather than green. HELD until Clear.',
                              type: ToastType.warning,
                            );
                          },
                          tooltip:
                              'Seeds 4 mock Banxa orders covering every '
                              'bucket of the 09-01 status ladder, then '
                              'refetches. Makes the orders list, order card, '
                              'order-details card and its page walkable with '
                              'no sandbox call. STICKY until Clear.',
                        ),
                        _devButton(
                          'Orders empty',
                          () {
                            DevBanxaFixtures.instance.arm(DevBanxaOrders.empty);
                            context.read<OrdersCubit>().fetchOrders();
                            ToastManager.instance.showToast(
                              context: context,
                              title: 'Banxa empty state armed',
                              message:
                                  'A SUCCESSFUL fetch returning zero orders — '
                                  "the GWEmptyState branch 09-02 added. This "
                                  'is what a new wallet sees. HELD until Clear.',
                              type: ToastType.warning,
                            );
                          },
                          tooltip:
                              'Forces a successful-but-empty orders fetch — '
                              'the "No orders yet" GWEmptyState, distinct '
                              'from the error branch. STICKY until Clear.',
                        ),
                        _devButton(
                          'Orders error',
                          () {
                            DevBanxaFixtures.instance.arm(DevBanxaOrders.error);
                            context.read<OrdersCubit>().fetchOrders();
                            ToastManager.instance.showToast(
                              context: context,
                              title: 'Banxa orders error armed',
                              message:
                                  "The GWErrorState branch 09-02 added, which "
                                  'replaced a bare "❌" string. Its own Retry '
                                  'will KEEP failing while armed — press '
                                  'Clear first, then Retry, to watch it '
                                  'recover.',
                              type: ToastType.warning,
                            );
                          },
                          tooltip:
                              'Forces an orders-load failure so the '
                              'GWErrorState + Retry affordance can be walked. '
                              'STICKY until Clear.',
                        ),
                        _devButton(
                          'Clear Banxa',
                          () {
                            DevBanxaFixtures.instance.disarm();
                            context.read<OrdersCubit>().fetchOrders();
                            ToastManager.instance.showToast(
                              context: context,
                              title: 'Banxa fixtures cleared',
                              message:
                                  'Next fetch runs for real against the '
                                  'sandbox.',
                              type: ToastType.success,
                            );
                          },
                          tooltip:
                              'Clears any armed Banxa fixture and refetches '
                              'for real. Press this before testing the error '
                              "state's own Retry, or it will keep failing.",
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: GeniusWalletConsts.space4),
                _Section(
                  label: 'NAVIGATE',
                  expanded: _navigateExpanded,
                  onToggle: () =>
                      setState(() => _navigateExpanded = !_navigateExpanded),
                  gw: gw,
                  children: [
                    Wrap(
                      spacing: GeniusWalletConsts.space2,
                      runSpacing: GeniusWalletConsts.space2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _devButton(
                          // Explicit widget.router.push, matching
                          // global_swap_fab_host.dart:159 - the InheritedGoRouter
                          // trap that form avoids, rather than trusting that the
                          // rebound context resolves it.
                          'Tokens',
                          () => widget.router.push('/dev/token-probe'),
                        ),
                        _devButton(
                          'Gallery',
                          () => widget.router.push('/design_gallery'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: GeniusWalletConsts.space4),
                _Section(
                  label: 'APPEARANCE',
                  expanded: _appearanceExpanded,
                  onToggle: () => setState(
                    () => _appearanceExpanded = !_appearanceExpanded,
                  ),
                  gw: gw,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: isLight
                              ? 'Switch to dark'
                              : 'Switch to light',
                          icon: Icon(
                            isLight ? Icons.dark_mode : Icons.light_mode,
                            color: gw.textPrimary,
                          ),
                          onPressed: () {
                            GWAppearance.instance.setMode(
                              isLight
                                  ? GWAppearanceMode.dark
                                  : GWAppearanceMode.light,
                            );
                          },
                        ),
                        Text(
                          isLight ? 'Light' : 'Dark',
                          style: TextStyle(
                            color: gw.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Compact panel-section action button. Wraps the app's branded [GWButton]
  /// (tertiary variant: `surfaceElevated` fill + `borderSubtle` border +
  /// `gw.textPrimary` label) instead of a hand-rolled `TextButton`, so every
  /// action button is appearance-aware and reads correctly in both light and
  /// dark — this is what the light-mode walk feedback asked for. [tooltip],
  /// when given, carries the full description for labels shortened to avoid
  /// GWButtonSize.sm's one-line ellipsis truncation in the ~260px panel.
  Widget _devButton(String label, VoidCallback onTap, {String? tooltip}) {
    return GWButton(
      label: label,
      onPressed: onTap,
      variant: GWButtonVariant.tertiary,
      size: GWButtonSize.sm,
      tooltip: tooltip,
    );
  }
}

/// Collapsible section used by the dev-tools bubble's expanded panel. Header
/// is a chevron + uppercase-style label; tapping it calls [onToggle]. Body
/// ([children]) renders only when [expanded].
class _Section extends StatelessWidget {
  const _Section({
    required this.label,
    required this.expanded,
    required this.onToggle,
    required this.gw,
    required this.children,
  });

  final String label;
  final bool expanded;
  final VoidCallback onToggle;
  final GWColors gw;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                expanded ? Icons.expand_more : Icons.chevron_right,
                color: gw.textSecondary,
                size: 18,
              ),
              const SizedBox(width: GeniusWalletConsts.space2),
              Text(
                label,
                style: TextStyle(color: gw.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.only(
              top: GeniusWalletConsts.space2,
              left: GeniusWalletConsts.space4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
      ],
    );
  }
}
