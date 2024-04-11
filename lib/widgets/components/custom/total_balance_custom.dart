import 'package:flutter/material.dart';

class TotalBalanceCustom extends StatefulWidget {
  final Widget? child;
  TotalBalanceCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _TotalBalanceCustomState createState() => _TotalBalanceCustomState();
}

class _TotalBalanceCustomState extends State<TotalBalanceCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
