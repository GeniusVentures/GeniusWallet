import 'package:flutter/material.dart';

class NavDashboardButtonCustom extends StatefulWidget {
  final Widget? child;
  NavDashboardButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _NavDashboardButtonCustomState createState() =>
      _NavDashboardButtonCustomState();
}

class _NavDashboardButtonCustomState extends State<NavDashboardButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
