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
import 'package:genius_wallet/network/network_dropdown_selector.dart';
import 'package:genius_wallet/reown/reown_connect_button.dart';
import 'package:genius_wallet/test/dev_tools_widget.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
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
    if (kDebugMode) const DevToolsWidget(),
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
    final destinations = _visibleDestinations;
    final selected = _currentIndex(context);

    return BottomNavigationBar(
      currentIndex: selected,
      onTap: (index) => context.go(destinations[index].path),
      items: destinations
          .map((d) => BottomNavigationBarItem(
                icon: Icon(d.icon),
                activeIcon: Icon(d.icon),
                label: d.label,
                tooltip: d.label,
              ))
          .toList(),
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
    final destinations = _visibleDestinations;
    final selected = _currentIndex(context);
    final hideLabels = MediaQuery.sizeOf(context).width < GeniusBreakpoints.xl;

    return ColoredBox(
      color: GeniusWalletColors.deepBlueCardColor,
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
                        ? Colors.greenAccent
                        : Colors.white.withValues(alpha: 0.6);

                    final tabButton = Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.go(dest.path),
                        borderRadius: BorderRadius.circular(
                            GeniusWalletConsts.borderRadiusCard),
                        mouseCursor: SystemMouseCursors.click,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 12.0),
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
                                        style: TextStyle(
                                            fontSize: 14, color: color),
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
                                        ? Colors.greenAccent
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
                spacing: 4.0,
                children: [
                  ..._buildActionRowWidgets(context),
                  ElevatedButton(
                      child: const Text(
                        "Buy GNUS",
                        style: TextStyle(fontSize: 14),
                      ),
                      onPressed: () async {
                        context.push('/buy');
                      }),
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
    return BlocBuilder<AppBloc, AppState>(builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Genius Wallet"),
          actions: [
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ..._buildActionRowWidgets(context),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: child,
        bottomNavigationBar: const _MobileTabBar(),
      );
    });
  }
}

class DesktopOverlay extends StatelessWidget {
  final Widget child;
  const DesktopOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GeniusWalletColors.deepBlueTertiary,
      appBar: const _DesktopTopBar(),
      body: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          return child;
        },
      ),
    );
  }
}
