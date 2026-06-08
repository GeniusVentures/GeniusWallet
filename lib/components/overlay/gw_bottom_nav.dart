import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/overlay/navigation_overlay_cubit.dart';
import 'package:genius_wallet/bloc/overlay/navigation_overlay_state.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

/// Clean flat bottom navigation, four destinations, cyan accent on the
/// selected item. Replaces the older `GeniusTabbar` BottomNavigationBar
/// styling for the new design system.
class GWBottomNav extends StatelessWidget {
  const GWBottomNav({super.key});

  static const List<_NavItem> _items = [
    _NavItem(
      screen: NavigationScreen.dashboard,
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      screen: NavigationScreen.markets,
      icon: Icons.stacked_line_chart_rounded,
      activeIcon: Icons.stacked_line_chart_rounded,
      label: 'Markets',
    ),
    _NavItem(
      screen: NavigationScreen.transactions,
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'Activity',
    ),
    _NavItem(
      screen: NavigationScreen.web,
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      label: 'Discover',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationOverlayCubit, NavigationOverlayState>(
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            gradient: GWDecorations.surfaceSheen,
            border: Border(
              top: BorderSide(
                color: GeniusWalletColors.borderSubtle,
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 60,
              child: Row(
                children: _items.map((item) {
                  final selected = state.selectedScreen == item.screen;
                  return Expanded(
                    child: _NavTile(
                      item: item,
                      selected: selected,
                      onTap: () => context
                          .read<NavigationOverlayCubit>()
                          .navigationTapped(item.screen),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? GeniusWalletColors.brandPrimary
        : GeniusWalletColors.textSecondary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? item.activeIcon : item.icon,
              size: 22,
              color: color,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: GeniusWalletTypography.labelMd.copyWith(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.screen,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final NavigationScreen screen;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}
