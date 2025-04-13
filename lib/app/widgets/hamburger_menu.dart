import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_cubit.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_state.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';
import 'package:genius_wallet/widgets/components/bottom_drawer/responsive_drawer.dart';

class HamburgerMenu extends StatelessWidget {
  const HamburgerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Material(
        color: Colors.transparent, // No background color
        child: InkWell(
          onTap: () => _showMenu(context),
          borderRadius: BorderRadius.circular(40),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(Icons.menu, size: 24, color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    ResponsiveDrawer.show<void>(
      context: context,
      title: 'Menu',
      children: const [
        _DrawerListTile(
          title: 'Markets',
          icon: Icons.line_axis,
          screen: NavigationScreen.markets,
        ),
        _DrawerListTile(
          title: 'Crypto News',
          icon: Icons.newspaper,
          screen: NavigationScreen.news,
        ),
        _DrawerListTile(
          title: 'Blockchain Events',
          icon: Icons.calendar_month,
          screen: NavigationScreen.events,
        ),
      ],
    );
  }
}

class _DrawerListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final NavigationScreen screen;

  const _DrawerListTile({
    required this.title,
    required this.icon,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      minLeadingWidth: 18,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: GeniusWalletFontSize.medium,
          color: Colors.white,
        ),
      ),
      onTap: () {
        context.read<NavigationOverlayCubit>().selectNavigation(screen);
        Navigator.of(context).pop();
      },
    );
  }
}
