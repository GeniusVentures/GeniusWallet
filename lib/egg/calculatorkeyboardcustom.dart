import 'package:flutter/material.dart';

class CalculatorKeyboardCustom extends StatefulWidget {
  final Widget child;
  CalculatorKeyboardCustom({Key key, this.child}) : super(key: key);

  @override
  _CalculatorKeyboardCustomState createState() =>
      _CalculatorKeyboardCustomState();
}

class _CalculatorKeyboardCustomState extends State<CalculatorKeyboardCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
