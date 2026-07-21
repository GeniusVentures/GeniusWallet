import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/banxa/banxa_components/buy_cancelled_drawer.dart';
import 'package:genius_wallet/banxa/banxa_components/buy_success_drawer.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/dev/dev_fault_injector.dart';
import 'package:genius_wallet/dev/dev_mock_holdings.dart';
import 'package:genius_wallet/dev/dev_mock_transactions.dart';
import 'package:genius_wallet/reown/approve_dapp_connection_drawer.dart';
import 'package:genius_wallet/reown/approve_transaction_drawer.dart';
import 'package:genius_wallet/reown/send_transaction_details.dart';
import 'package:genius_wallet/reown/swap_result_drawer.dart';
import 'package:genius_wallet/squid_router/swap_fail_drawer.dart';
import 'package:genius_wallet/squid_router/swap_success_drawer.dart';
import 'package:genius_wallet/test/dev_overrides.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

/// Draggable, dev-only overlay bubble (kDebugMode && kShowDevTools, gated at
/// the insertion site — see [responsive_overlay.dart]'s DesktopOverlay /
/// MobileOverlay). Replaces the old header-row [DevToolsWidget], which was
/// prepended to `_buildActionRowWidgets` and RenderFlex-overflowed
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
class DevToolsBubble extends StatefulWidget {
  const DevToolsBubble({super.key});

  @override
  State<DevToolsBubble> createState() => _DevToolsBubbleState();
}

class _DevToolsBubbleState extends State<DevToolsBubble> {
  static const double _collapsedSize = 48.0;
  static const double _desiredPanelWidth = 260.0;

  // Small margin kept from every viewport edge (and from the header).
  static const double _edgeInset = GeniusWalletConsts.space4;
  static const double _headerHeight = GeniusWalletConsts.appBarHeight;

  // (dx, dy) = (inset from the RIGHT edge, inset from the TOP edge) — NOT a
  // left/top offset. Positioned(right:, top:) anchors the top-right corner,
  // so the expanded panel grows down-and-left from the bubble's corner for
  // free. Lazily initialised on first build (needs MediaQuery, unavailable
  // in initState).
  //
  // ponytail: not persisted across app restarts — dev-only, a fresh corner
  // position each launch is an acceptable ceiling.
  Offset? _position;
  bool _expanded = false;

  // Per-section expand state for the panel body (D-01 default states: MOCK
  // and APPEARANCE open on first show, TEST FLOWS and NAVIGATE collapsed).
  bool _mockExpanded = true;
  bool _testFlowsExpanded = false;
  bool _navigateExpanded = false;
  bool _appearanceExpanded = true;

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
    final minRight = _edgeInset;
    final maxRightRaw = screenSize.width - width - _edgeInset;
    final maxRight = maxRightRaw < minRight ? minRight : maxRightRaw;

    final minTop = _headerHeight + _edgeInset;
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
          _position ?? Offset(_edgeInset, _headerHeight + _edgeInset);
      // Anchor is (rightInset, topInset): moving the pointer right shrinks
      // the right inset; moving it down grows the top inset.
      final updated = Offset(current.dx - delta.dx, current.dy + delta.dy);
      _position = _clamp(updated, screenSize, width, height);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    _position ??= Offset(_edgeInset, _headerHeight + _edgeInset);

    final panelMaxWidth = _panelMaxWidth(screenSize);
    final panelMaxHeight = _panelMaxHeight(screenSize);
    final currentWidth = _expanded ? panelMaxWidth : _collapsedSize;
    final currentHeight = _expanded ? panelMaxHeight : _collapsedSize;
    final position = _clamp(_position!, screenSize, currentWidth, currentHeight);

    return ValueListenableBuilder<GWAppearanceMode>(
      valueListenable: GWAppearance.instance,
      builder: (context, mode, _) {
        final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
        final isLight = GWAppearance.isLight;

        return Positioned(
          right: position.dx,
          top: position.dy,
          child: _expanded
              ? _buildExpandedPanel(
                  context,
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
                        _devButton(
                          'Long',
                          () {
                            DevMockHoldings.instance.loadExtreme();
                            context
                                .read<WalletDetailsCubit>()
                                .injectMockCoins(
                                  DevMockHoldings.instance.coins,
                                  balance:
                                      DevMockHoldings.instance.totalBalance,
                                );
                          },
                          tooltip: 'Long / extreme values',
                        ),
                        _devButton(
                          'No icon',
                          () {
                            DevMockHoldings.instance.loadMissingIcon();
                            context
                                .read<WalletDetailsCubit>()
                                .injectMockCoins(
                                  DevMockHoldings.instance.coins,
                                  balance:
                                      DevMockHoldings.instance.totalBalance,
                                );
                          },
                          tooltip: 'Missing icon scenario',
                        ),
                        _devButton(
                          'Mock txns',
                          () {
                            context.read<TransactionsCubit>().addTransactions(
                              DevMockTransactions.instance.batch(
                                isSgnus: false,
                              ),
                            );
                            final sgnusTxController = context
                                .read<GeniusApi>()
                                .getSGNUSTransactionsController();
                            for (final tx in DevMockTransactions.instance
                                .batch(isSgnus: true)) {
                              sgnusTxController.addTransaction(tx);
                            }
                            ToastManager.instance.showToast(
                              context: context,
                              title: 'Mock transactions added',
                              message: 'Added 8 mock transactions',
                              type: ToastType.success,
                            );
                          },
                          tooltip: 'Inject mock transactions batch',
                        ),
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
                        _devButton('Clear', () {
                          DevMockHoldings.instance.clear();
                          DevFaultInjector.instance.disarm();
                          context.read<WalletDetailsCubit>().clearMock();
                          context.read<TransactionsCubit>().clear();
                          context
                              .read<GeniusApi>()
                              .getSGNUSTransactionsController()
                              .clear();
                        }),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: GeniusWalletConsts.space4),
                _Section(
                  label: 'TEST FLOWS',
                  expanded: _testFlowsExpanded,
                  onToggle: () => setState(
                    () => _testFlowsExpanded = !_testFlowsExpanded,
                  ),
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
                        _devButton(
                          'Add tx',
                          () {
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
                          },
                          tooltip: 'Add SGNUS Test Transaction',
                        ),
                        _devButton(
                          'Conn',
                          () {
                            ApproveDappConnectionDrawer.show(
                              context: context,
                              dappName: 'uniswap',
                              dappUrl: 'uniswap.org',
                              dappDescription:
                                  'UniSwap is a decentralized exchange protocol that allows users to swap various cryptocurrencies directly from their wallets without the need for an intermediary.',
                              iconUrl: 'https://uniswap.org/favicon.ico',
                            );
                          },
                          tooltip: 'Test Approve Connection Drawer',
                        ),
                        _devButton(
                          'Swap OK',
                          () {
                            SwapResultDrawer.show(
                              context: context,
                              isSuccess: true,
                              txHash:
                                  '0x0f9b1b9a7c65dd5c1c0c0ef879b1dd73bb7f7f2187bbf1a8329c7edc9b3d4abc',
                              coinSymbol: 'ETH',
                            );
                          },
                          tooltip: 'Test Swap Result Drawer (Success)',
                        ),
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
                        _devButton(
                          'Appr',
                          () {
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
                          },
                          tooltip: 'Test Approve Swap Drawer',
                        ),
                        _devButton(
                          'Succeed',
                          () {
                            SwapSuccessDrawer.show(
                              context,
                              fromAmount: '1.0',
                              toAmount: '0.98',
                              fromSymbol: 'ETH',
                              toSymbol: 'USDC',
                              fromIconUrl:
                                  'https://assets.coingecko.com/coins/images/279/large/ethereum.png',
                              toIconUrl:
                                  'https://assets.coingecko.com/coins/images/6319/large/USD_Coin_icon.png',
                              chain: 'Ethereum',
                            );
                          },
                          tooltip: 'Test Swap Success Drawer',
                        ),
                        _devButton(
                          'Failed',
                          () {
                            SwapFailDrawer.show(
                              context,
                              fromAmount: '1.0',
                              toAmount: '0.00',
                              fromSymbol: 'ETH',
                              toSymbol: 'USDC',
                              fromIconUrl:
                                  'https://assets.coingecko.com/coins/images/279/large/ethereum.png',
                              toIconUrl:
                                  'https://assets.coingecko.com/coins/images/6319/large/USD_Coin_icon.png',
                              chain: 'Ethereum',
                            );
                          },
                          tooltip: 'Test Swap Failed Drawer',
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
                _Section(
                  label: 'NAVIGATE',
                  expanded: _navigateExpanded,
                  onToggle: () => setState(
                    () => _navigateExpanded = !_navigateExpanded,
                  ),
                  gw: gw,
                  children: [
                    Wrap(
                      spacing: GeniusWalletConsts.space2,
                      runSpacing: GeniusWalletConsts.space2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _devButton(
                          'Tokens',
                          () => context.push('/dev/token-probe'),
                        ),
                        _devButton(
                          'Gallery',
                          () => context.push('/design_gallery'),
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
