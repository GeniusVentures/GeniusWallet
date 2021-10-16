import 'package:flutter/material.dart';

class Bell extends StatefulWidget {
  final Widget child;
  Bell({Key key, this.child}) : super(key: key);

  @override
  _BellState createState() => _BellState();
}

class _BellState extends State<Bell> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
