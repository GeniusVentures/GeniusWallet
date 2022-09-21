import 'package:flutter/material.dart';

class OrderHistoryCustom extends StatefulWidget {
  final Widget? child;
  OrderHistoryCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _OrderHistoryCustomState createState() => _OrderHistoryCustomState();
}

class _OrderHistoryCustomState extends State<OrderHistoryCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
