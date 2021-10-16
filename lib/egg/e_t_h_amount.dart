import 'package:flutter/material.dart';

class ETHAmount extends StatefulWidget {
  final Widget child;
  ETHAmount({Key key, this.child}) : super(key: key);

  @override
  _ETHAmountState createState() => _ETHAmountState();
}

class _ETHAmountState extends State<ETHAmount> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
