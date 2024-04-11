import 'package:flutter/material.dart';

class TransactionStatusCustom extends StatefulWidget {
  final Widget? child;
  const TransactionStatusCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _TransactionStatusCustomState createState() =>
      _TransactionStatusCustomState();
}

class _TransactionStatusCustomState extends State<TransactionStatusCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
