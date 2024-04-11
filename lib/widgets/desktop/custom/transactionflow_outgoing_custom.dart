import 'package:flutter/material.dart';

class TransactionflowOutgoingCustom extends StatefulWidget {
  final Widget? child;
  const TransactionflowOutgoingCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _TransactionflowOutgoingCustomState createState() =>
      _TransactionflowOutgoingCustomState();
}

class _TransactionflowOutgoingCustomState
    extends State<TransactionflowOutgoingCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
