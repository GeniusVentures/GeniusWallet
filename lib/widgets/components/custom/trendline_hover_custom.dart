import 'package:flutter/material.dart';

class TrendlineHoverCustom extends StatefulWidget {
  final Widget? child;
  TrendlineHoverCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _TrendlineHoverCustomState createState() => _TrendlineHoverCustomState();
}

class _TrendlineHoverCustomState extends State<TrendlineHoverCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
