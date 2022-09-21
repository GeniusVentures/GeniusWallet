import 'package:flutter/material.dart';

class SellLimitOrdersCustom extends StatefulWidget {
  final Widget? child;
  SellLimitOrdersCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _SellLimitOrdersCustomState createState() => _SellLimitOrdersCustomState();
}

class _SellLimitOrdersCustomState extends State<SellLimitOrdersCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
