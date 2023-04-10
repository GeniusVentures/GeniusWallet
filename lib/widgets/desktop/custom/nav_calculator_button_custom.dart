import 'package:flutter/material.dart';

class NavCalculatorButtonCustom extends StatefulWidget {
  final Widget? child;
  NavCalculatorButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _NavCalculatorButtonCustomState createState() =>
      _NavCalculatorButtonCustomState();
}

class _NavCalculatorButtonCustomState extends State<NavCalculatorButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
