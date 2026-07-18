import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/account/account_dropdown_selector.dart';
import 'package:genius_wallet/account/sdk_account_manager.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/dev/dev_flags.dart';
import 'package:genius_wallet/network/network_dropdown_selector.dart';
import 'package:genius_wallet/reown/reown_connect_button.dart';
import 'package:genius_wallet/test/dev_tools_widget.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

class _TabDestination {
  final String path;
  final String label;
  final IconData icon;
  final bool visible;

  const _TabDestination({
    required this.path,
    required this.label,
    required this.icon,
    this.visible = true,
  });
}

final List<_TabDestination> _allDestinations = [
  const _TabDestination(
    path: '/dashboard',
    label: 'Dashboard',
    icon: Icons.dashboard,
  ),
  _TabDestination(
    path: '/transactions',
    label: 'Transactions',
    icon: FontAwesomeIcons.clock.data,
  ),
  const _TabDestination(
    path: '/swap',
    label: 'Swap',
    icon: Icons.swap_horiz_outlined,
  ),
  const _TabDestination(
    path: '/markets',
    label: 'Markets',
    icon: Icons.stacked_line_chart,
  ),
  const _TabDestination(
    path: '/news',
    label: 'News',
    icon: Icons.library_books,
  ),
  _TabDestination(
    path: '/web',
    label: 'Web',
    icon: FontAwesomeIcons.globe.data,
    visible: !Platform.isLinux,
  ),
  const _TabDestination(
    path: '/logs',
    label: 'Feedback',
    icon: Icons.feedback_outlined,
  ),
  const _TabDestination(
    path: '/settings',
    label: 'Settings',
    icon: Icons.settings,
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
  return 0;
}

List<Widget> _buildActionRowWidgets(BuildContext context) {
  final walletDetailsCubit = context.read<WalletDetailsCubit>();
  return [
    // Dev test buttons (transaction / swap / buy). Opt-in — see [kShowDevTools];
    // always-on in debug, they crowd and overflow the real action row.
    if (kDebugMode && kShowDevTools) const DevToolsWidget(),
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

class _MobileTabBar extends StatelessWidget {
  const _MobileTabBar();

  @override
  Widget build(BuildContext context) {
    // Fail-soft GWColors read (04-02 const-widget live-flip pattern) --
    // this widget is const-instanced (`bottomNavigationBar: const
    // _MobileTabBar()`), so appearance-aware tokens must come from the
    // Theme.of(context) InheritedWidget dependency, not a static getter.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final destinations = _visibleDestinations;
    final selected = _currentIndex(context);

    // Background: GWDecorations.surfaceSheen (Gen-B's token vocabulary,
    // §2.5) -- a top-lit gradient consistent with the rest of the redesign's
    // elevated surfaces, rather than a flat transparent fill. Safe to read
    // directly (not gated through `gw`): it is itself appearance-aware
    // (GWAppearance.isLight) and, because this Container lives inside
    // _MobileTabBar's build(), it is only ever evaluated on a build() call
    // already forced by the `gw` read above.
    return Container(
      decoration: BoxDecoration(
        gradient: GWDecorations.surfaceSheen,
        border: Border(
          top: BorderSide(color: gw.borderSubtle, width: 0.5),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: selected,
        onTap: (index) => context.go(destinations[index].path),
        selectedItemColor: GeniusWalletColors.brandPrimary,
        unselectedItemColor: gw.textSecondary,
        selectedIconTheme: const IconThemeData(
          color: GeniusWalletColors.brandPrimary,
        ),
        unselectedIconTheme: IconThemeData(color: gw.textSecondary),
        selectedLabelStyle: GeniusWalletTypography.labelMd.copyWith(
          color: GeniusWalletColors.brandPrimary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GeniusWalletTypography.labelMd.copyWith(
          color: gw.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        items: destinations
            .map(
              (d) => BottomNavigationBarItem(
                icon: Icon(d.icon),
                activeIcon: Icon(d.icon),
                label: d.label,
                tooltip: d.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DesktopTopBar extends StatelessWidget implements PreferredSizeWidget {
  const _DesktopTopBar();

  @override
  Size get preferredSize =>
      const Size.fromHeight(GeniusWalletConsts.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final destinations = _visibleDestinations;
    final selected = _currentIndex(context);
    final hideLabels = MediaQuery.sizeOf(context).width < GeniusBreakpoints.xxl;

    return ColoredBox(
      color: gw.surfaceElevated,
      child: SizedBox(
        height: GeniusWalletConsts.appBarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
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
                  ),
                  ...destinations.indexed.map((entry) {
                    final (index, dest) = entry;
                    final isSelected = index == selected;
                    final color = isSelected
                        ? GeniusWalletColors.brandPrimary
                        : gw.textSecondary;

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
                            vertical: 6.0,
                            horizontal: 12.0,
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
                                      dest.icon,
                                      size: _kIconSize,
                                      color: color,
                                    ),
                                    if (!hideLabels) ...[
                                      Text(
                                        dest.label,
                                        style: GeniusWalletTypography.labelMd
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
                                        ? GeniusWalletColors.brandPrimary
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
                  ElevatedButton(
                    child: Text(
                      "Buy GNUS",
                      style: GeniusWalletTypography.labelMd,
                    ),
                    onPressed: () async {
                      context.push('/buy');
                    },
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
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return Scaffold(
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
          body: child,
          bottomNavigationBar: const _MobileTabBar(),
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
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Scaffold(
      backgroundColor: gw.surfaceBase,
      appBar: const _DesktopTopBar(),
      body: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          return child;
        },
      ),
    );
  }
}
