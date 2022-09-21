import 'package:flutter/material.dart';

class CurrencyToggleCustom extends StatefulWidget {
  final Widget? child;
  CurrencyToggleCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _CurrencyToggleCustomState createState() => _CurrencyToggleCustomState();
}

class _CurrencyToggleCustomState extends State<CurrencyToggleCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
