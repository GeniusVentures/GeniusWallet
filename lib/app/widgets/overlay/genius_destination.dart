import 'package:flutter/material.dart';

class GeniusDestination {
  /// Indicates what screen should be pushed when [this] is clicked.
  final String destination;
  final Widget icon;
  final Widget? selectedIcon;
  final Text label;
  const GeniusDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.destination,
  });
}
