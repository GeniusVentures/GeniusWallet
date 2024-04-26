import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:genius_wallet/app/widgets/overlay/genius_destination.dart';

class GeniusTabDestinations {
  static final destinations = [
    const GeniusDestination(
        destination: '/dashboard',
        icon: Icon(Icons.dashboard),
        label: Text('Dashboard'),
        selectedIcon: Icon(Icons.dashboard)),
    const GeniusDestination(
      destination: '/wallets',
      icon: Icon(Icons.account_balance_wallet),
      label: Text('Wallets'),
      selectedIcon: Icon(Icons.account_balance_wallet),
    ),
    const GeniusDestination(
        destination: '/transactions',
        icon: Icon(Icons.timer_rounded),
        label: Text('Transactions'),
        selectedIcon: Icon(Icons.timer_rounded)),
    const GeniusDestination(
      destination: '/trade',
      icon: Icon(Icons.candlestick_chart),
      label: Text('Trade'),
      selectedIcon: Icon(Icons.candlestick_chart),
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
