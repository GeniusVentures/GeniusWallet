import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/account/account_dropdown_selector.dart';
import 'package:genius_wallet/account/sdk_account_manager.dart';
import 'package:genius_wallet/banxa/banxa_components/buy_gnus_button.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/overlay/gw_bottom_nav.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/network/network_dropdown_selector.dart';
import 'package:genius_wallet/preferences/preferences_button.dart';
import 'package:genius_wallet/reown/reown_connect_button.dart';
import 'package:genius_wallet/test/dev_tools_widget.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

class _TabDestination {
  final String path;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool visible;

  const _TabDestination({
    required this.path,
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.visible = true,
  });
}

final List<_TabDestination> _allDestinations = [
  const _TabDestination(
    path: '/dashboard',
    label: 'Dashboard',
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
  ),
  const _TabDestination(
    path: '/transactions',
    label: 'Transactions',
    icon: Icons.receipt_long_outlined,
    activeIcon: Icons.receipt_long_rounded,
  ),
  const _TabDestination(
    path: '/swap',
    label: 'Swap',
    icon: Icons.swap_horiz_outlined,
    activeIcon: Icons.swap_horiz_rounded,
  ),
  const _TabDestination(
    path: '/markets',
    label: 'Markets',
    icon: Icons.stacked_line_chart_rounded,
    activeIcon: Icons.stacked_line_chart_rounded,
  ),
  const _TabDestination(
    path: '/news',
    label: 'News',
    icon: Icons.library_books_outlined,
    activeIcon: Icons.library_books,
  ),
  _TabDestination(
    path: '/browser',
    label: 'Web',
    icon: Icons.explore_outlined,
    activeIcon: Icons.explore_rounded,
    visible: !Platform.isLinux,
  ),
  const _TabDestination(
    path: '/logs',
    label: 'Feedback',
    icon: Icons.feedback_outlined,
    activeIcon: Icons.feedback_rounded,
  ),
  const _TabDestination(
    path: '/settings',
    label: 'Settings',
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings,
  ),
];

List<_TabDestination> get _visibleDestinations =>
    _allDestinations.where((d) => d.visible).toList();

int _currentIndex(BuildContext context) {
  final location = GoRouterState.of(context).uri.path;
  final visible = _visibleDestinations;
  for (var i = 0; i < visible.length; i++) {
    if (location.startsWith(visible[i].path)) return i;
  }
  // '/web' is the WebView renderer pushed *by* the '/browser' tab (the dApp
  // launcher) — it has no destination of its own, so alias it to '/browser'
  // so the nav doesn't fall through to Dashboard while a web page is open.
  if (location.startsWith('/web')) {
    final browserIndex = visible.indexWhere((d) => d.path == '/browser');
    if (browserIndex != -1) return browserIndex;
  }
  return 0;
}

List<Widget> _buildActionRowWidgets(BuildContext context) {
  final walletDetailsCubit = context.read<WalletDetailsCubit>();
  return [
    if (kDebugMode) const DevToolsWidget(),
    const PreferencesButton(),
    const NetworkDropdownSelector(),
    const SDKAccountManagerButton(),
    AccountDropdownSelector(),
    ReownConnectButton(
      walletAddress: walletDetailsCubit.state.selectedWallet?.address ?? '',
      geniusApi: context.read<GeniusApi>(),
      walletDetailsCubit: walletDetailsCubit,
      transactionsCubit: context.read<TransactionsCubit>(),
    ),
  ];
}

const _kIconSize = 16.0;

class _DesktopTopBar extends StatelessWidget implements PreferredSizeWidget {
  const _DesktopTopBar();

  @override
  Size get preferredSize =>
      const Size.fromHeight(GeniusWalletConsts.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final destinations = _visibleDestinations;
    final selected = _currentIndex(context);
    final hideLabels = MediaQuery.sizeOf(context).width < GeniusBreakpoints.xxl;

    return ColoredBox(
      color: GeniusWalletColors.deepBlueCardColor,
      child: SizedBox(
        height: GeniusWalletConsts.appBarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: GeniusWalletConsts.space6,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: hideLabels ? 6 : 2,
                children: [
                  Image.asset(
                    'assets/images/geniusappbarlogo.png',
                    height: 30,
                    package: 'genius_wallet',
                    semanticLabel: 'Genius Wallet logo',
                  ),
                  ...destinations.indexed.map((entry) {
                    final (index, dest) = entry;
                    final isSelected = index == selected;
                    final color = isSelected
                        ? GeniusWalletColors.brandGreen
                        : GeniusWalletColors.textPrimary60;

                    final tabButton = Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.go(dest.path),
                        borderRadius: BorderRadius.circular(
                          GeniusWalletConsts.borderRadiusCard,
                        ),
                        mouseCursor: SystemMouseCursors.click,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: GeniusWalletConsts.space6 / 2,
                            horizontal: GeniusWalletConsts.space6,
                          ),
                          child: Ink(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 4,
                              children: [
                                Row(
                                  spacing: 6,
                                  children: [
                                    Icon(
                                      isSelected ? dest.activeIcon : dest.icon,
                                      size: _kIconSize,
                                      color: color,
                                    ),
                                    if (!hideLabels) ...[
                                      Text(
                                        dest.label,
                                        style: GeniusWalletTypography.bodyMd
                                            .copyWith(color: color),
                                      ),
                                    ],
                                  ],
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 1,
                                  width: hideLabels ? 20 : 60,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? GeniusWalletColors.brandGreen
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );

                    return hideLabels
                        ? Tooltip(message: dest.label, child: tabButton)
                        : tabButton;
                  }),
                ],
              ),
              Row(
                children: [
                  ..._buildActionRowWidgets(context),
                  BuyGnusButton(
                    userEmail: '',
                    walletAddress: context
                            .read<WalletDetailsCubit>()
                            .state
                            .selectedWallet
                            ?.address ??
                        '',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MobileOverlay extends StatelessWidget {
  final Widget child;
  const MobileOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final destinations = _visibleDestinations;
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: GeniusWalletColors.surfaceBase,
          appBar: AppBar(
            title: const Text("Genius Wallet"),
            actions: [
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [..._buildActionRowWidgets(context)]),
                ),
              ),
            ],
          ),
          body: GWCanvasBackground(child: child),
          bottomNavigationBar: GWBottomNav(
            destinations: destinations
                .map((d) => GWNavDestination(
                      path: d.path,
                      label: d.label,
                      icon: d.icon,
                      activeIcon: d.activeIcon,
                    ))
                .toList(),
            selectedIndex: _currentIndex(context),
          ),
        );
      },
    );
  }
}

class DesktopOverlay extends StatelessWidget {
  final Widget child;
  const DesktopOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GeniusWalletColors.surfaceBase,
      appBar: const _DesktopTopBar(),
      body: GWCanvasBackground(
        child: BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            return child;
          },
        ),
      ),
    );
  }
}
