import 'package:flutter/material.dart';

class TransactionTypeIconCustom extends StatefulWidget {
  final Widget? child;
  TransactionTypeIconCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _TransactionTypeIconCustomState createState() =>
      _TransactionTypeIconCustomState();
}

class _TransactionTypeIconCustomState extends State<TransactionTypeIconCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
