import 'package:flutter/material.dart';

class Amount extends StatefulWidget {
  final Widget child;
  Amount({Key key, this.child}) : super(key: key);

  @override
  _AmountState createState() => _AmountState();
}

class _AmountState extends State<Amount> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
