import 'package:flutter/material.dart';

class Arrow extends StatefulWidget {
  final Widget child;
  Arrow({Key key, this.child}) : super(key: key);

  @override
  _ArrowState createState() => _ArrowState();
}

class _ArrowState extends State<Arrow> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
