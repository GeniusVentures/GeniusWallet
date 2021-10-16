import 'package:flutter/material.dart';

class MaxETH extends StatefulWidget {
  final Widget child;
  MaxETH({Key key, this.child}) : super(key: key);

  @override
  _MaxETHState createState() => _MaxETHState();
}

class _MaxETHState extends State<MaxETH> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
