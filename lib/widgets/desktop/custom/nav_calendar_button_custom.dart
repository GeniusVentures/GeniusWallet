import 'package:flutter/material.dart';

class NavCalendarButtonCustom extends StatefulWidget {
  final Widget? child;
  NavCalendarButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _NavCalendarButtonCustomState createState() =>
      _NavCalendarButtonCustomState();
}

class _NavCalendarButtonCustomState extends State<NavCalendarButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
