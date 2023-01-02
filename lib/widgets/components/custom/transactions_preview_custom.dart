import 'package:flutter/material.dart';

class TransactionsPreviewCustom extends StatefulWidget {
  final Widget? child;
  TransactionsPreviewCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _TransactionsPreviewCustomState createState() =>
      _TransactionsPreviewCustomState();
}

class _TransactionsPreviewCustomState extends State<TransactionsPreviewCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
