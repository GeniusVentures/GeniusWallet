import 'package:flutter/material.dart';

class YearSelectorCustom extends StatefulWidget {
  final Widget? child;
  YearSelectorCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _YearSelectorCustomState createState() => _YearSelectorCustomState();
}

class _YearSelectorCustomState extends State<YearSelectorCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
