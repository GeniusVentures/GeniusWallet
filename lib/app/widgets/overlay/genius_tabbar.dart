import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_cubit.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_state.dart';
import 'package:genius_wallet/app/widgets/overlay/destinations.dart';

class GeniusTabbar extends StatelessWidget {
  static const _numTabs = 5;
  const GeniusTabbar({super.key});

  @override
  Widget build(BuildContext context) {
    final destinations = _buildDestinations();
    return BlocBuilder<NavigationOverlayCubit, NavigationOverlayState>(
      builder: (context, state) {
        return BottomNavigationBar(
            backgroundColor: Colors.transparent,
            enableFeedback: false,
            onTap: (int index) {
              context.read<NavigationOverlayCubit>().navigationTapped(index);
            },
            currentIndex: state.selectedScreen.index >= _numTabs
                ? 0
                : state.selectedScreen.index,
            items: destinations);
      },
    );
  }

  List<BottomNavigationBarItem> _buildDestinations() {
    return GeniusTabDestinations.destinations
        .take(_numTabs)
        .map(
          (e) => BottomNavigationBarItem(
            backgroundColor: Colors.transparent,
            tooltip: e.label.data,
            icon: Container(padding: const EdgeInsets.all(8), child: e.icon),
            activeIcon: Container(
                padding: const EdgeInsets.all(8), child: e.selectedIcon),
            label: e.label.data,
          ),
        )
        .toList();
  }
}
