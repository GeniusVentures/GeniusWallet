import 'package:flutter/material.dart';

class NavStatsButtonCustom extends StatefulWidget {
  final Widget? child;
  NavStatsButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _NavStatsButtonCustomState createState() => _NavStatsButtonCustomState();
}

class _NavStatsButtonCustomState extends State<NavStatsButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
