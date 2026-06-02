import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/account/account_dropdown_selector.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/network/network_dropdown_selector.dart';
import 'package:genius_wallet/reown/reown_connect_button.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

class TabDestination {
  final String path;
  final String label;
  final IconData icon;
  final IconData? selectedIcon; // falls back to icon if null
  final bool visible;

  const TabDestination({
    required this.path,
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.visible = true,
  });

  IconData get activeIcon => selectedIcon ?? icon;
}

final List<TabDestination> _allDestinations = [
  const TabDestination(
    path: '/dashboard',
    label: 'Dashboard',
    icon: Icons.dashboard,
  ),
  TabDestination(
    path: '/transactions',
    label: 'Transactions',
    icon: FontAwesomeIcons.clock.data,
  ),
  const TabDestination(
    path: '/swap',
    label: 'Swap',
    icon: Icons.swap_horiz_outlined,
  ),
  const TabDestination(
    path: '/markets',
    label: 'Markets',
    icon: Icons.stacked_line_chart,
  ),
  const TabDestination(
    path: '/news',
    label: 'News',
    icon: Icons.library_books,
  ),
  TabDestination(
    path: '/web',
    label: 'Web',
    icon: FontAwesomeIcons.globe.data,
    visible: !Platform.isLinux,
  ),
];

List<TabDestination> get _visibleDestinations =>
    _allDestinations.where((d) => d.visible).toList();

int _currentIndex(BuildContext context) {
  final location = GoRouterState.of(context).uri.path;
  final visible = _visibleDestinations;
  for (var i = 0; i < visible.length; i++) {
    if (location.startsWith(visible[i].path)) return i;
  }
  return 0;
}

class MobileTabBar extends StatelessWidget {
  const MobileTabBar({super.key});

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
                activeIcon: Icon(d.activeIcon),
                label: d.label,
                tooltip: d.label,
              ))
          .toList(),
    );
  }
}

const _kIconSize = 16.0;

class DesktopTopBar extends StatelessWidget implements PreferredSizeWidget {
  const DesktopTopBar({super.key});

  @override
  Size get preferredSize =>
      const Size.fromHeight(GeniusWalletConsts.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final destinations = _visibleDestinations;
    final selected = _currentIndex(context);
    final hideLabels = MediaQuery.sizeOf(context).width < GeniusBreakpoints.xl;
    final walletDetailsCubit = context.read<WalletDetailsCubit>();

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
                spacing: 2,
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

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.go(dest.path),
                        borderRadius: BorderRadius.circular(
                            GeniusWalletConsts.borderRadiusCard),
                        mouseCursor: SystemMouseCursors.click,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 12.0),
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
                                        style: TextStyle(
                                            fontSize: 14, color: color),
                                      ),
                                    ],
                                  ],
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 1,
                                  width: 60,
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
                  }),
                ],
              ),
              Row(
                spacing: 4.0,
                children: [
                  const NetworkDropdownSelector(),
                  AccountDropdownSelector(),
                  ReownConnectButton(
                    walletAddress:
                        walletDetailsCubit.state.selectedWallet?.address ?? '',
                    geniusApi: context.read<GeniusApi>(),
                    walletDetailsCubit: walletDetailsCubit,
                    transactionsCubit: context.read<TransactionsCubit>(),
                  ),
                  ElevatedButton(
                      child: const Text(
                        "Buy GNUS",
                        style: TextStyle(fontSize: 14),
                      ),
                      onPressed: () async {
                        context.push('/buy');
                      })
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
