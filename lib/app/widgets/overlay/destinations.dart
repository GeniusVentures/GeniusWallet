import 'package:flutter/material.dart';
import 'package:genius_wallet/app/widgets/overlay/genius_destination.dart';

// This order must match whats in `navigation_overlay_state/NavigationScreen` enum
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
    const GeniusDestination(
        destination: '/markets',
        label: Text('Markets'),
        icon: Icon(Icons.stacked_line_chart),
        selectedIcon: Icon(Icons.stacked_line_chart)),
    const GeniusDestination(
      destination: '/calculator',
      label: Text('Calculator'),
      icon: Icon(Icons.calculate),
      selectedIcon: Icon(Icons.calculate),
    ),
    const GeniusDestination(
      destination: '/news',
      label: Text('News'),
      icon: Icon(Icons.library_books),
      selectedIcon: Icon(Icons.library_books),
    ),
    const GeniusDestination(
      destination: '/events',
      label: Text('Events'),
      icon: Icon(Icons.calendar_month),
      selectedIcon: Icon(Icons.calendar_month),
    ),
    const GeniusDestination(
      destination: '/settings',
      label: Text('Settings'),
      icon: Icon(Icons.settings),
      selectedIcon: Icon(Icons.settings),
    ),
  ];
}
