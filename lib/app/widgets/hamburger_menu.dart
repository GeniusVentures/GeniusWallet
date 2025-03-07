import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_cubit.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_state.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';

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
              menuIcon: Icon(Icons.line_axis),
              screen: NavigationScreen.markets,
            ),
            MenuListTile(
              menuTitle: 'Crypto News',
              menuIcon: Icon(Icons.newspaper),
              screen: NavigationScreen.news,
            ),
            MenuListTile(
              menuTitle: 'Blockchain Events',
              menuIcon: Icon(Icons.calendar_month),
              screen: NavigationScreen.events,
            ),
            MenuListTile(
              menuTitle: 'Settings',
              menuIcon: Icon(Icons.settings),
              screen: NavigationScreen.settings,
            )
          ],
        ),
      ),
    );
  }
}

class MenuListTile extends ListTile {
  final String menuTitle;
  final Widget menuIcon;
  final NavigationScreen screen;

  const MenuListTile(
      {Key? key,
      this.menuTitle = '',
      required this.menuIcon,
      required this.screen})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(menuTitle),
        titleAlignment: ListTileTitleAlignment.center,
        leading: menuIcon,
        minLeadingWidth: 18,
        onTap: () {
          context.read<NavigationOverlayCubit>().selectNavigation(screen);
          Scaffold.of(context).closeEndDrawer();
        });
  }
}
