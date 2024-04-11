import 'package:flutter/material.dart';

class TrendLineCustom extends StatefulWidget {
  final Widget? child;
  TrendLineCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _TrendLineCustomState createState() => _TrendLineCustomState();
}

class _TrendLineCustomState extends State<TrendLineCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
