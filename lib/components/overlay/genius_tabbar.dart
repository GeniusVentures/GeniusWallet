



import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/overlay/navigation_overlay_cubit.dart';
import 'package:genius_wallet/bloc/overlay/navigation_overlay_state.dart';
import 'package:genius_wallet/components/overlay/destinations.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:flutter/gestures.dart';


class GeniusTabbar extends StatelessWidget {
  static const _numTabs = 6;
  const GeniusTabbar({super.key});

  @override
  Widget build(BuildContext context) {
    final destinations = _buildDestinations();
    final screenList = destinations.map((e) => e.key).toList();

    return BlocBuilder<NavigationOverlayCubit, NavigationOverlayState>(
      builder: (context, state) {
        final selectedScreen = state.selectedScreen;
        final selectedIndex = screenList.indexOf(selectedScreen);

        return Container(
          color: GeniusWalletColors.deepBlueCardColor,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ScrollConfiguration(
            behavior: const _TabBarScrollBehavior(),
            child: Scrollbar(
              thumbVisibility: true,
              interactive: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(destinations.length, (index) {
                    final entry = destinations[index];
                    final isSelected = index == selectedIndex;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          context.read<NavigationOverlayCubit>().navigationTapped(screenList[index]);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? GeniusWalletColors.lightGreenPrimary.withOpacity(0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              entry.value.activeIcon ?? entry.value.icon,
                              const SizedBox(height: 4),
                              Text(
                                entry.value.label ?? '',
                                style: TextStyle(
                                  color: isSelected ? GeniusWalletColors.lightGreenPrimary : Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom scroll behavior to enable mouse drag and wheel scrolling for horizontal tab bar
class _TabBarScrollBehavior extends MaterialScrollBehavior {
  const _TabBarScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => const <PointerDeviceKind>{
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}

// Helper to build the destinations list
List<MapEntry<NavigationScreen, BottomNavigationBarItem>> _buildDestinations() {
  return GeniusTabDestinations.destinations
      .where((e) => e.isVisible ?? true)
      .take(GeniusTabbar._numTabs)
      .map((e) {
    final navScreen = e.navScreen;
    return MapEntry(
      navScreen,
      BottomNavigationBarItem(
        backgroundColor: Colors.transparent,
        tooltip: e.label.data,
        icon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Container(height: 1, width: 40, color: Colors.transparent),
            const SizedBox(height: 8),
            e.icon,
          ],
        ),
        activeIcon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Container(
                height: 1,
                width: 40,
                color: GeniusWalletColors.lightGreenPrimary),
            const SizedBox(height: 8),
            e.selectedIcon ?? e.icon,
          ],
        ),
        label: e.label.data,
      ),
    );
  }).toList();
}
