import 'package:flutter/material.dart';

class TransactionCounterCustom extends StatefulWidget {
  final Widget? child;
  TransactionCounterCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _TransactionCounterCustomState createState() =>
      _TransactionCounterCustomState();
}

class _TransactionCounterCustomState extends State<TransactionCounterCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
