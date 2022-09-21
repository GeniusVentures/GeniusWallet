import 'package:flutter/material.dart';

class BuyButtonCustom extends StatefulWidget {
  final Widget? child;
  BuyButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _BuyButtonCustomState createState() => _BuyButtonCustomState();
}

class _BuyButtonCustomState extends State<BuyButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
