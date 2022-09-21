import 'package:flutter/material.dart';

class ChartOptionsCustom extends StatefulWidget {
  final Widget? child;
  ChartOptionsCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _ChartOptionsCustomState createState() => _ChartOptionsCustomState();
}

class _ChartOptionsCustomState extends State<ChartOptionsCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
