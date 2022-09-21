import 'package:flutter/material.dart';

class DateRangeCustom extends StatefulWidget {
  final Widget? child;
  DateRangeCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _DateRangeCustomState createState() => _DateRangeCustomState();
}

class _DateRangeCustomState extends State<DateRangeCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
