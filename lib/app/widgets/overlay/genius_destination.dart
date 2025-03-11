import 'package:flutter/material.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_state.dart';

class GeniusDestination {
  /// Indicates what screen should be pushed when [this] is clicked.
  final String destination;
  final Widget icon;
  final Widget? selectedIcon;
  final Text label;
  final NavigationScreen navScreen;
  final bool? isVisible;
  const GeniusDestination(
      {required this.icon,
      this.selectedIcon,
      required this.label,
      required this.destination,
      this.isVisible,
      required this.navScreen});
}
