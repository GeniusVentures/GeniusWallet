import 'package:flutter/material.dart';

class NavTimerButtonCustom extends StatefulWidget {
  final Widget? child;
  NavTimerButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _NavTimerButtonCustomState createState() => _NavTimerButtonCustomState();
}

class _NavTimerButtonCustomState extends State<NavTimerButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
