import 'package:flutter/material.dart';

class DetailedTransactionStatusCustom extends StatefulWidget {
  final Widget? child;
  DetailedTransactionStatusCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _DetailedTransactionStatusCustomState createState() =>
      _DetailedTransactionStatusCustomState();
}

class _DetailedTransactionStatusCustomState
    extends State<DetailedTransactionStatusCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
