import 'package:flutter/material.dart';

class PreviousMonthButtonCustom extends StatefulWidget {
  final Widget? child;
  PreviousMonthButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _PreviousMonthButtonCustomState createState() =>
      _PreviousMonthButtonCustomState();
}

class _PreviousMonthButtonCustomState extends State<PreviousMonthButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
