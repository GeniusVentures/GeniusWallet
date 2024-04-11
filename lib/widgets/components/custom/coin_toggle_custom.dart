import 'package:flutter/material.dart';

class CoinToggleCustom extends StatefulWidget {
  final Widget? child;
  CoinToggleCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _CoinToggleCustomState createState() => _CoinToggleCustomState();
}

class _CoinToggleCustomState extends State<CoinToggleCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
