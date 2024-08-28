import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_cubit.dart';
import 'package:genius_wallet/app/widgets/overlay/destinations.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

class DesktopOverlay extends StatelessWidget {
  final Widget child;
  const DesktopOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: GeniusWalletColors.deepBlueTertiary,
        body: Row(
          children: [
            const _DesktopSideRail(),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _DesktopSideRail extends StatelessWidget {
  const _DesktopSideRail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final destinations = _buildDestinations();
    return SingleChildScrollView(
        child: ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            child: IntrinsicHeight(
                child: NavigationRail(
              destinations: destinations,
              onDestinationSelected: (index) => context
                  .read<NavigationOverlayCubit>()
                  .navigationTapped(index),
              selectedIndex: context
                  .watch<NavigationOverlayCubit>()
                  .state
                  .selectedScreen
                  .index,
              leading: Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 20),
                child: Image.asset('assets/images/geniusappbarlogo.png',
                    package: 'genius_wallet'),
              ),
            ))));
  }

  List<NavigationRailDestination> _buildDestinations() {
    return GeniusTabDestinations.destinations
        .map((e) => NavigationRailDestination(
            icon: e.icon, label: e.label, selectedIcon: e.selectedIcon))
        .toList();
  }
}
