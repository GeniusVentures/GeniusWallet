import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_cubit.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_state.dart';
import 'package:genius_wallet/app/widgets/overlay/destinations.dart';
import 'package:genius_wallet/app/widgets/test/dev_overrides.dart';
import 'package:genius_wallet/app/widgets/test/test_transaction_button.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

class DesktopOverlay extends StatelessWidget {
  final Widget child;
  const DesktopOverlay({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: GeniusWalletColors.deepBlueTertiary,
        body: Row(children: [const _DesktopSideRail(), Expanded(child: child)]),
      ),
    );
  }
}

class _DesktopSideRail extends StatelessWidget {
  const _DesktopSideRail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final destinations = _buildDestinations();
    final screenList = destinations.map((e) => e.key).toList();

    final selectedScreen =
        context.watch<NavigationOverlayCubit>().state.selectedScreen;

    final selectedIndex = screenList.indexOf(selectedScreen);

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: IntrinsicHeight(
          child: NavigationRail(
            destinations: destinations.map((e) => e.value).toList(),
            onDestinationSelected: (index) {
              final selectedScreen = screenList[index];
              context
                  .read<NavigationOverlayCubit>()
                  .navigationTapped(selectedScreen);
            },
            selectedIndex: selectedIndex,
            leading: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 20, left: 4),
              child: Column(children: [
                // FOR TESTING TRANSACTION STREAMING
                if (isWalletPKBypass()) ...[
                  const TestTransactionButton(),
                  const SizedBox(height: 20)
                ],
                Image.asset(
                  'assets/images/geniusappbarlogo.png',
                  package: 'genius_wallet',
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }

  List<MapEntry<NavigationScreen, NavigationRailDestination>>
      _buildDestinations() {
    return GeniusTabDestinations.destinations
        .where((e) =>
            e.isVisible ?? true) // Optional: Add your visibility condition
        .map(
          (e) => MapEntry(
            e.navScreen,
            NavigationRailDestination(
              icon: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Tooltip(
                  message: e.label.data ?? "",
                  child: e.icon,
                ),
              ),
              label: e.label,
              selectedIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: e.selectedIcon,
              ),
            ),
          ),
        )
        .toList();
  }
}
