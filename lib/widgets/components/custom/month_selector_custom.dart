import 'package:flutter/material.dart';

class MonthSelectorCustom extends StatefulWidget {
  final Widget? child;
  MonthSelectorCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _MonthSelectorCustomState createState() => _MonthSelectorCustomState();
}

class _MonthSelectorCustomState extends State<MonthSelectorCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
