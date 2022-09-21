import 'package:flutter/material.dart';

class CurrencyDropdownCustom extends StatefulWidget {
  final Widget? child;
  CurrencyDropdownCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _CurrencyDropdownCustomState createState() => _CurrencyDropdownCustomState();
}

class _CurrencyDropdownCustomState extends State<CurrencyDropdownCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
