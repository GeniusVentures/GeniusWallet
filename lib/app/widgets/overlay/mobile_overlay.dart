import 'package:flutter/material.dart';
import 'package:genius_wallet/app/widgets/hamburger_menu.dart';
import 'package:genius_wallet/app/widgets/overlay/genius_tabbar.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/widgets/components/genius_appbar.g.dart';

class MobileOverlay extends StatelessWidget {
  final Widget child;
  const MobileOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const HamburgerMenu(),
      backgroundColor: GeniusWalletColors.deepBlueTertiary,
      body: Column(
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: GeniusWalletConsts.horizontalPadding),
            height: 55,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return GeniusAppbar(constraints);
              },
            ),
          ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: const GeniusTabbar(),
    );
  }
}
