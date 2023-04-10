import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:genius_wallet/app/widgets/overlay/genius_destination.dart';

class GeniusTabDestinations {
  static final destinations = [
    GeniusDestination(
      destination: '/dashboard',
      icon: Image.asset(
        'assets/images/navdashboardbuttoncustom.png',
        package: 'genius_wallet',
      ),
      label: const Text('Dashboard'),
      selectedIcon: Image.asset(
        'assets/images/navdashboardbuttonactive.png',
        package: 'genius_wallet',
      ),
    ),
    GeniusDestination(
      destination: '/wallets',
      icon: Image.asset(
        'assets/images/navwalletbuttoncustom.png',
        package: 'genius_wallet',
      ),
      label: const Text('Wallets'),
      selectedIcon: Image.asset(
        'assets/images/navwalletbuttonactive.png',
        package: 'genius_wallet',
      ),
    ),
    GeniusDestination(
      destination: '/transactions',
      icon: Image.asset(
        'assets/images/navtimerbuttoncustom.png',
        package: 'genius_wallet',
      ),
      label: const Text('Transactions'),
      selectedIcon: Image.asset(
        'assets/images/navtimerbuttonactive.png',
        package: 'genius_wallet',
      ),
    ),
    GeniusDestination(
      destination: '/trade',
      icon: SvgPicture.asset(
        'assets/images/tradedesktopiconunselected.svg',
        package: 'genius_wallet',
      ),
      label: const Text('Trade'),
      selectedIcon: SvgPicture.asset(
        'assets/images/tradedesktopiconselected.svg',
        package: 'genius_wallet',
      ),
    ),
    GeniusDestination(
      destination: '/markets',
      icon: Image.asset(
        'assets/images/navstatsbuttoncustom.png',
        package: 'genius_wallet',
      ),
      label: const Text('Markets'),
      selectedIcon: Image.asset(
        'assets/images/navstatsbuttonactive.png',
        package: 'genius_wallet',
      ),
    ),
    GeniusDestination(
      destination: '/events',
      icon: Image.asset(
        'assets/images/navcalendarbuttoncustom.png',
        package: 'genius_wallet',
      ),
      label: const Text('Events'),
      selectedIcon: Image.asset(
        'assets/images/navcalendarbuttonactive.png',
        package: 'genius_wallet',
      ),
    ),
    GeniusDestination(
      destination: '/calculator',
      icon: Image.asset(
        'assets/images/navcalculatorbuttoncustom.png',
        package: 'genius_wallet',
      ),
      label: const Text('Calculator'),
      selectedIcon: Image.asset(
        'assets/images/navcalculatorbuttonactive.png',
        package: 'genius_wallet',
      ),
    ),
    GeniusDestination(
      destination: '/news',
      icon: Image.asset(
        'assets/images/navnewsbuttoncustom.png',
        package: 'genius_wallet',
      ),
      label: const Text('News'),
      selectedIcon: Image.asset(
        'assets/images/navnewsbuttonactive.png',
        package: 'genius_wallet',
      ),
    ),
  ];
}
