import 'package:flutter/material.dart';

class DaySelectorCustom extends StatefulWidget {
  final Widget? child;
  DaySelectorCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _DaySelectorCustomState createState() => _DaySelectorCustomState();
}

class _DaySelectorCustomState extends State<DaySelectorCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
