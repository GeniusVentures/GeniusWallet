import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/account/account_dropdown_selector.dart';
import 'package:genius_wallet/banxa/banxa_components/buy_gnus_button.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/network/network_dropdown_selector.dart';
import 'package:genius_wallet/reown/reown_connect_button.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
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
              ))
          .toList(),
    );
  }
}

const _kIconSize = 16.0;

class DesktopTopBar extends StatelessWidget {
  const DesktopTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final destinations = _visibleDestinations;
    final selected = _currentIndex(context);
    final hideLabels = MediaQuery.sizeOf(context).width < 1300;
    final walletDetailsCubit = context.read<WalletDetailsCubit>();

    return ColoredBox(
      color: GeniusWalletColors.deepBlueCardColor,
      child: SizedBox(
        height: GeniusWalletConsts.appBarHeight,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Image.asset(
                      'assets/images/geniusappbarlogo.png',
                      height: 30,
                      package: 'genius_wallet',
                    ),
                  ),
                  ...destinations.indexed.map((entry) {
                    final (index, dest) = entry;
                    final isSelected = index == selected;
                    final color = isSelected
                        ? Colors.greenAccent
                        : Colors.white.withAlpha(153);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.go(dest.path),
                          borderRadius: BorderRadius.circular(6),
                          hoverColor: Colors.white.withAlpha(25),
                          mouseCursor: SystemMouseCursors.click,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected ? dest.activeIcon : dest.icon,
                                      size: _kIconSize,
                                      color: color,
                                    ),
                                    if (!hideLabels) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        dest.label,
                                        style: TextStyle(
                                            fontSize: 14, color: color),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
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
                    );
                  }),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 8),
                  const NetworkDropdownSelector(),
                  const SizedBox(width: 8),
                  const SizedBox(width: 155, child: AccountDropdownSelector()),
                  ReownConnectButton(
                    walletAddress:
                        walletDetailsCubit.state.selectedWallet?.address ?? '',
                    geniusApi: context.read<GeniusApi>(),
                    walletDetailsCubit: walletDetailsCubit,
                    transactionsCubit: context.read<TransactionsCubit>(),
                  ),
                  const SizedBox(width: 8),
                  BuyGnusButton(
                    userEmail: '',
                    walletAddress:
                        walletDetailsCubit.state.selectedWallet?.address ?? '',
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
