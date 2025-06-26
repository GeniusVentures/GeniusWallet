import 'package:flutter/material.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:provider/provider.dart';

import 'package:genius_wallet/components/overlay/side_meun.dart';
import 'package:genius_wallet/components/overlay/menu_app_controller.dart';
import "package:genius_wallet/components/overlay/responsive_overlay.dart";

class MainBoardScreen extends StatelessWidget {
  const MainBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuAppController>(
      builder: (context, controller, child) {
        return Scaffold(
          key: controller.scaffoldKey,
          drawer: const SideMenu(),
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (GeniusBreakpoints.useDesktopOverlay(context) &&
                    controller.showDesktopSideMenu)
                  const Expanded(child: SideMenu()),
                const Expanded(flex: 6, child: ResponsiveOverlay()),
              ],
            ),
          ),
        );
      },
    );
  }
}
