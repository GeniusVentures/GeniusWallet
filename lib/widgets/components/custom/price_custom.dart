import 'package:flutter/material.dart';

class PriceCustom extends StatefulWidget {
  final Widget? child;
  PriceCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _PriceCustomState createState() => _PriceCustomState();
}

class _PriceCustomState extends State<PriceCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
