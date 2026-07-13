import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:go_router/go_router.dart';

/// One destination in the bottom bar. `activeIcon` is shown when selected —
/// the redesign's outlined -> filled swap.
class GWNavDestination {
  const GWNavDestination({
    required this.path,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// Mobile bottom navigation, redesign skin, driven by go_router paths.
///
/// Visuals are the redesign's `GWBottomNav` (surface sheen, subtle top border,
/// cyan `brandPrimary` on the selected item). The layout is a themed
/// [BottomNavigationBar] rather than the redesign's Row-of-Expanded tiles: the
/// redesign shipped 4 destinations, develop's shell has 8, and 8 labelled
/// Expanded tiles do not fit.
class GWBottomNav extends StatelessWidget {
  const GWBottomNav({
    super.key,
    required this.destinations,
    required this.selectedIndex,
  });

  final List<GWNavDestination> destinations;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: GWDecorations.surfaceSheen,
        border: Border(
          top: BorderSide(color: GeniusWalletColors.borderSubtle, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => context.go(destinations[index].path),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconSize: 22,
          selectedItemColor: GeniusWalletColors.brandPrimary,
          unselectedItemColor: GeniusWalletColors.textSecondary,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: GeniusWalletTypography.labelMd.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GeniusWalletTypography.labelMd.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          items: destinations
              .map(
                (d) => BottomNavigationBarItem(
                  icon: Icon(d.icon),
                  activeIcon: Icon(d.activeIcon),
                  label: d.label,
                  tooltip: d.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
