import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_state.dart';
import 'package:genius_wallet/app/widgets/overlay/genius_destination.dart';

// This order must match whats in `navigation_overlay_state/NavigationScreen` enum
double iconSize = 24.0;

class GeniusTabDestinations {
  static final destinations = [
    GeniusDestination(
        navScreen: NavigationScreen.dashboard,
        destination: '/dashboard',
        icon: Icon(Icons.dashboard, size: iconSize),
        label: const Text('Dashboard'),
        selectedIcon: Icon(Icons.dashboard, size: iconSize)),
    GeniusDestination(
        navScreen: NavigationScreen.transactions,
        destination: '/transactions',
        icon: Icon(FontAwesomeIcons.clock, size: iconSize),
        label: const Text('Transactions'),
        selectedIcon: Icon(FontAwesomeIcons.clock, size: iconSize)),
    GeniusDestination(
        navScreen: NavigationScreen.web,
        destination: '/web',
        icon: Icon(FontAwesomeIcons.globe, size: iconSize),
        label: const Text('Web'),
        selectedIcon: Icon(FontAwesomeIcons.globe, size: iconSize),
        isVisible: !Platform.isLinux), // HIDE ON LINUX
    GeniusDestination(
        navScreen: NavigationScreen.markets,
        destination: '/markets',
        label: const Text('Markets'),
        icon: Icon(Icons.stacked_line_chart, size: iconSize),
        selectedIcon: Icon(Icons.stacked_line_chart, size: iconSize)),
    GeniusDestination(
      navScreen: NavigationScreen.news,
      destination: '/news',
      label: const Text('News'),
      icon: Icon(Icons.library_books, size: iconSize),
      selectedIcon: Icon(Icons.library_books, size: iconSize),
    ),
  ];
}
