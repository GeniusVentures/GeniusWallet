import 'package:flutter/material.dart';

class Selections extends StatefulWidget {
  final Widget child;
  Selections({Key key, this.child}) : super(key: key);

  @override
  _SelectionsState createState() => _SelectionsState();
}

class _SelectionsState extends State<Selections> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
