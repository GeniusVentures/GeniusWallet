import 'package:flutter/material.dart';

class TransactionflowIncomingCustom extends StatefulWidget {
  final Widget? child;
  const TransactionflowIncomingCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _TransactionflowIncomingCustomState createState() =>
      _TransactionflowIncomingCustomState();
}

class _TransactionflowIncomingCustomState
    extends State<TransactionflowIncomingCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
