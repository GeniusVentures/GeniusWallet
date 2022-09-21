import 'package:flutter/material.dart';

class TransactionFilterCustom extends StatefulWidget {
  final Widget? child;
  TransactionFilterCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _TransactionFilterCustomState createState() =>
      _TransactionFilterCustomState();
}

class _TransactionFilterCustomState extends State<TransactionFilterCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
