import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/account/account_dropdown_selector.dart';
import 'package:genius_wallet/bloc/overlay/navigation_overlay_cubit.dart';
import 'package:genius_wallet/bloc/overlay/navigation_overlay_state.dart';
import 'package:genius_wallet/reown/reown_connect_button.dart';
import 'package:genius_wallet/components/overlay/destinations.dart';
import 'package:genius_wallet/test/dev_overrides.dart';
import 'package:genius_wallet/test/test_transaction_button.dart';
import 'package:genius_wallet/network/network_dropdown_selector.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class DesktopTopBar extends StatelessWidget {
  const DesktopTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final destinations = _buildDestinations();
    final screenList = destinations.map((e) => e.key).toList();

    final isHideMenuText = MediaQuery.of(context).size.width < 1200;

    final selectedScreen =
        context.watch<NavigationOverlayCubit>().state.selectedScreen;
    final selectedIndex = screenList.indexOf(selectedScreen);

    final geniusApi = context.read<GeniusApi>();
    final WalletDetailsCubit walletDetailsCubit =
        context.read<WalletDetailsCubit>();

    return Container(
      height: GeniusWalletConsts.appBarHeight,
      color: GeniusWalletColors.deepBlueCardColor,
      padding: const EdgeInsets.only(left: 16, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Image.asset(
              'assets/images/geniusappbarlogo.png',
              height: 30,
              package: 'genius_wallet',
            ),
          ),

          // Navigation Buttons
          Row(children: [
            // FOR TESTING TRANSACTION STREAMING
            // if (isWalletPKBypass()) ...[
            //   const TestTransactionButton(),
            //   const SizedBox(height: 20)
            // ],
            ...destinations.asMap().entries.map((entry) {
              final index = entry.key;
              final screen = screenList[index];
              final destination = entry.value.value;
              final isSelected = index == selectedIndex;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () {
                    context
                        .read<NavigationOverlayCubit>()
                        .navigationTapped(screen);
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      children: [
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
                        if (!isHideMenuText) ...[
                          const SizedBox(width: 6),
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
                      ],
                    ),
                  ),
                ),
              );
            })
          ]),
          Row(children: [
            const SizedBox(width: 8),
            const NetworkDropdownSelector(),
            const SizedBox(width: 8),
            const SizedBox(width: 155, child: AccountDropdownSelector()),
            ReownConnectButton(
                walletAddress:
                    walletDetailsCubit.state.selectedWallet?.address ?? "",
                geniusApi: geniusApi,
                walletDetailsCubit: walletDetailsCubit),
          ])
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
