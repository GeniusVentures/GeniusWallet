import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/overlay/navigation_overlay_cubit.dart';
import 'package:genius_wallet/bloc/overlay/navigation_overlay_state.dart';
import 'package:genius_wallet/components/overlay/destinations.dart';

class GeniusTabbar extends StatelessWidget {
  static const _numTabs = 5;
  const GeniusTabbar({super.key});

  @override
  Widget build(BuildContext context) {
    final destinations = _buildDestinations();
    final screenList = destinations.map((e) => e.key).toList();

    return BlocBuilder<NavigationOverlayCubit, NavigationOverlayState>(
      builder: (context, state) {
        final selectedScreen = state.selectedScreen;

        // Get the index in the currently visible screens
        final selectedIndex = screenList.indexOf(selectedScreen);

        return BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          enableFeedback: false,
          currentIndex: selectedIndex >= 0 ? selectedIndex : 0,
          onTap: (int index) {
            final tappedScreen = screenList[index];
            context
                .read<NavigationOverlayCubit>()
                .navigationTapped(tappedScreen);
          },
          items: destinations.map((e) => e.value).toList(),
        );
      },
    );
  }

  List<MapEntry<NavigationScreen, BottomNavigationBarItem>>
      _buildDestinations() {
    return GeniusTabDestinations.destinations
        .where((e) => e.isVisible ?? true)
        .take(_numTabs)
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
              Container(
                  height: 1,
                  width: 40,
                  color: Colors.transparent), // empty bar for unselected
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
                  color: Colors.greenAccent), // green line
              const SizedBox(height: 8),
              e.selectedIcon ?? e.icon, // use selected icon if available
            ],
          ),
          label: e.label.data,
        ),
      );
    }).toList();
  }
}
