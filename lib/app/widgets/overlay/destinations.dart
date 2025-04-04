import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_state.dart';
import 'package:genius_wallet/app/widgets/overlay/genius_destination.dart';

// This order must match whats in `navigation_overlay_state/NavigationScreen` enum
class GeniusTabDestinations {
  static final destinations = [
    const GeniusDestination(
        navScreen: NavigationScreen.dashboard,
        destination: '/dashboard',
        icon: Icon(Icons.dashboard),
        label: Text('Dashboard'),
        selectedIcon: Icon(Icons.dashboard)),
    const GeniusDestination(
      navScreen: NavigationScreen.wallets,
      destination: '/wallets',
      icon: Icon(Icons.account_balance_wallet),
      label: Text('Wallets'),
      selectedIcon: Icon(Icons.account_balance_wallet),
    ),
    const GeniusDestination(
        navScreen: NavigationScreen.transactions,
        destination: '/transactions',
        icon: Icon(Icons.timer_rounded),
        label: Text('Transactions'),
        selectedIcon: Icon(Icons.timer_rounded)),
    const GeniusDestination(
      navScreen: NavigationScreen.trade,
      destination: '/trade',
      icon: Icon(Icons.candlestick_chart),
      label: Text('Trade'),
      selectedIcon: Icon(Icons.candlestick_chart),
    ),
    GeniusDestination(
        navScreen: NavigationScreen.web,
        destination: '/web',
        icon: const Icon(FontAwesomeIcons.globe),
        label: const Text('Web Browser'),
        selectedIcon: const Icon(FontAwesomeIcons.globe),
        isVisible: !Platform.isLinux), // HIDE ON LINUX
    const GeniusDestination(
        navScreen: NavigationScreen.markets,
        destination: '/markets',
        label: Text('Markets'),
        icon: Icon(Icons.stacked_line_chart),
        selectedIcon: Icon(Icons.stacked_line_chart)),
    const GeniusDestination(
      navScreen: NavigationScreen.news,
      destination: '/news',
      label: Text('News'),
      icon: Icon(Icons.library_books),
      selectedIcon: Icon(Icons.library_books),
    ),
    const GeniusDestination(
      navScreen: NavigationScreen.events,
      destination: '/events',
      label: Text('Events'),
      icon: Icon(Icons.calendar_month),
      selectedIcon: Icon(Icons.calendar_month),
    ),
    const GeniusDestination(
      navScreen: NavigationScreen.settings,
      destination: '/settings',
      label: Text('Settings'),
      icon: Icon(Icons.settings),
      selectedIcon: Icon(Icons.settings),
    ),
  ];
}
