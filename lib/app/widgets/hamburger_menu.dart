import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';
import 'package:go_router/go_router.dart';

class HamburgerMenu extends StatelessWidget {
  const HamburgerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.copyWith(
              bodyLarge: const TextStyle(
                fontSize: GeniusWalletFontSize.medium,
                color: Colors.white,
              ),
            ),
      ),
      child: Drawer(
        backgroundColor: GeniusWalletColors.deepBlueMenu,
        child: ListView(
          children: const [
            SizedBox(
              height: 20,
            ),
            MenuListTile(
              menuTitle: 'Markets',
              menuIcon: 'assets/images/chart.png',
              menuRoute: '/markets',
            ),
            MenuListTile(
              menuTitle: 'Crypto News',
              menuIcon: 'assets/images/news.png',
              menuRoute: '/news',
            ),
            MenuListTile(
              menuTitle: 'Blockchain Events',
              menuIcon: 'assets/images/calendar.png',
              menuRoute: '/events',
            ),
            MenuListTile(
              menuTitle: 'Calculator',
              menuIcon: 'assets/images/calculator.png',
              menuRoute: '/calculator',
            ),
            MenuListTile(
              menuTitle: 'Settings',
              menuIcon: 'assets/images/settings.png',
              menuRoute: '/settings',
            )
          ],
        ),
      ),
    );
  }
}

class MenuListTile extends ListTile {
  final String menuTitle;
  final String menuIcon;
  final String menuRoute;

  const MenuListTile(
      {Key? key, this.menuTitle = '', this.menuIcon = '', this.menuRoute = ''})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(menuTitle),
        titleAlignment: ListTileTitleAlignment.center,
        leading: Image.asset(menuIcon),
        minLeadingWidth: 18,
        onTap: () {
          context.go(menuRoute);
        });
  }
}
