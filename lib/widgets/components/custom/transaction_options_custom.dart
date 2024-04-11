import 'package:flutter/material.dart';

class TransactionOptionsCustom extends StatefulWidget {
  final Widget? child;
  const TransactionOptionsCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _TransactionOptionsCustomState createState() =>
      _TransactionOptionsCustomState();
}

class _TransactionOptionsCustomState extends State<TransactionOptionsCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
