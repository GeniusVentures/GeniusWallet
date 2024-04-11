import 'package:flutter/material.dart';

class TrendlineWithAxesCustom extends StatefulWidget {
  final Widget? child;
  TrendlineWithAxesCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _TrendlineWithAxesCustomState createState() =>
      _TrendlineWithAxesCustomState();
}

class _TrendlineWithAxesCustomState extends State<TrendlineWithAxesCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
