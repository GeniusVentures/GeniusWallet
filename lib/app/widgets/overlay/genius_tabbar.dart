import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_cubit.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_state.dart';
import 'package:genius_wallet/app/widgets/overlay/destinations.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

class GeniusTabbar extends StatelessWidget {
  static const _numTabs = 4;
  const GeniusTabbar({super.key});

  @override
  Widget build(BuildContext context) {
    final destinations = _buildDestinations();
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: GeniusWalletColors.blue500,
            width: 2,
          ),
        ),
      ),
      child: BlocBuilder<NavigationOverlayCubit, NavigationOverlayState>(
        builder: (context, state) {
          return BottomNavigationBar(
            onTap: (int index) {
              context.read<NavigationOverlayCubit>().navigationTapped(index);
            },
            currentIndex: state.selectedScreen.index >= _numTabs
                ? 0
                : state.selectedScreen.index,
            backgroundColor: GeniusWalletColors.gray800,
            type: BottomNavigationBarType.fixed,
            items: destinations,
          );
        },
      ),
    );
  }

  List<BottomNavigationBarItem> _buildDestinations() {
    return GeniusTabDestinations.destinations
        .take(_numTabs)
        .map(
          (e) => BottomNavigationBarItem(
            icon: e.icon,
            activeIcon: e.selectedIcon,
            label: e.label.data,
          ),
        )
        .toList();
  }
}
