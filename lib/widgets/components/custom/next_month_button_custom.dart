import 'package:flutter/material.dart';

class NextMonthButtonCustom extends StatefulWidget {
  final Widget? child;
  NextMonthButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _NextMonthButtonCustomState createState() => _NextMonthButtonCustomState();
}

class _NextMonthButtonCustomState extends State<NextMonthButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
