import 'package:flutter/material.dart';

class PriceGraphCustom extends StatefulWidget {
  final Widget? child;
  PriceGraphCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _PriceGraphCustomState createState() => _PriceGraphCustomState();
}

class _PriceGraphCustomState extends State<PriceGraphCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
