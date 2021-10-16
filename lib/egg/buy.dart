import 'package:flutter/material.dart';

class Buy extends StatefulWidget {
  final Widget child;
  Buy({Key key, this.child}) : super(key: key);

  @override
  _BuyState createState() => _BuyState();
}

class _BuyState extends State<Buy> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
