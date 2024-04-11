import 'package:flutter/material.dart';

class BuyLimitOrdersCustom extends StatefulWidget {
  final Widget? child;
  const BuyLimitOrdersCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _BuyLimitOrdersCustomState createState() => _BuyLimitOrdersCustomState();
}

class _BuyLimitOrdersCustomState extends State<BuyLimitOrdersCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
