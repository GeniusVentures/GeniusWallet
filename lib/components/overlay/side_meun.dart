import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/account/account_dropdown_selector.dart';
import 'package:genius_wallet/banxa/buy_gnus_button.dart';
import 'package:genius_wallet/bloc/overlay/navigation_overlay_cubit.dart';
import 'package:genius_wallet/bloc/overlay/navigation_overlay_state.dart';
import 'package:genius_wallet/components/overlay/destinations.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/components/overlay/menu_app_controller.dart';
import 'package:genius_wallet/network/network_dropdown_selector.dart';
import 'package:genius_wallet/reown/reown_connect_button.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:provider/provider.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final destinations = _buildDestinations();
    final screenList = destinations.map((e) => e.key).toList();

    // final isHideMenuText = MediaQuery.of(context).size.width < 1300;

    final selectedScreen =
        context.watch<NavigationOverlayCubit>().state.selectedScreen;
    final selectedIndex = screenList.indexOf(selectedScreen);

    return Container(
      //width: GeniusWalletConsts.appBarWidth,
      color: GeniusWalletColors.deepBlueCardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(children: [
            DrawerHeader(
              child: GestureDetector(
                onTap: () {
                  context.read<MenuAppController>().toggleDesktopSideMenu();
                },
                child: Image.asset(
                  'assets/images/geniusappbarlogo.png',
                  height: 30,
                  package: 'genius_wallet',
                ),
              ),
            ),
            ...destinations.asMap().entries.map((entry) {
              final index = entry.key;
              final screen = screenList[index];
              final destination = entry.value.value;
              final isSelected = index == selectedIndex;

              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 8), // Added vertical padding
                child: InkWell(
                  onTap: () {
                    context
                        .read<NavigationOverlayCubit>()
                        .navigationTapped(screen);
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: double
                            .infinity, // Make container full width for proper alignment
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12), // Increased vertical padding
                        child: Row(children: [
                          IconTheme(
                            data: IconThemeData(
                                size: 16,
                                color: isSelected
                                    ? Colors.greenAccent
                                    : Colors.white.withOpacity(0.6)),
                            child: isSelected
                                ? destination.selectedIcon
                                : destination.icon,
                          ),
                          // if (!isHideMenuText) ...[
                          const SizedBox(width: 15),
                          DefaultTextStyle(
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? Colors.greenAccent
                                  : Colors.white.withOpacity(0.6),
                            ),
                            child: destination.label,
                          ),
                        ]
                            // ],
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList()
          ]),
        ],
      ),
    );
  }

  List<MapEntry<NavigationScreen, NavigationRailDestination>>
      _buildDestinations() {
    return GeniusTabDestinations.destinations
        .where((e) => e.isVisible ?? true)
        .map(
          (e) => MapEntry(
            e.navScreen,
            NavigationRailDestination(
              icon: Tooltip(
                message: e.label.data ?? "",
                child: e.icon,
              ),
              label: e.label,
              selectedIcon: e.selectedIcon,
            ),
          ),
        )
        .toList();
  }
}
