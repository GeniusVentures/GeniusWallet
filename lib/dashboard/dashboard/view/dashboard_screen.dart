import 'package:flutter/material.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/dashboard/dashboard/widgets/horizontal_wallets_scrollview.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/genius_appbar.g.dart';
import 'package:genius_wallet/widgets/components/markets_module.g.dart';
import 'package:genius_wallet/widgets/components/wallets_overview.g.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreenView(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              SizedBox(
                height: 100,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return GeniusAppbar(constraints);
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: const Text(
                  'Dashboard',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 300,
                width: MediaQuery.of(context).size.width,
                child: LayoutBuilder(builder: (context, constraints) {
                  return WalletsOverview(constraints);
                }),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('My Wallets', style: TextStyle(fontSize: 16)),
                    MaterialButton(
                      onPressed: () {
                        /// TODO: Take to create/add wallet
                      },
                      child: const Text(
                        'Add Wallet',
                        style: TextStyle(color: GeniusWalletColors.blue500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const HorizontalWalletsScrollview(),
              const SizedBox(height: 14),
              SizedBox(
                height: 500,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return MarketsModule(constraints);
                  },
                ),
              ),
            ],
          ),
        ),
        footer: Container(),
      ),
    );
  }
}
