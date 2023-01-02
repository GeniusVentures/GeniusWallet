import 'package:flutter/material.dart';

class DetailedTransactionOptionsCustom extends StatefulWidget {
  final Widget? child;
  DetailedTransactionOptionsCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _DetailedTransactionOptionsCustomState createState() =>
      _DetailedTransactionOptionsCustomState();
}

class _DetailedTransactionOptionsCustomState
    extends State<DetailedTransactionOptionsCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
