import 'package:flutter/material.dart';

class ButtonActiveCustom extends StatefulWidget {
  final Widget child;
  ButtonActiveCustom({Key key, this.child}) : super(key: key);

  @override
  _ButtonActiveCustomState createState() => _ButtonActiveCustomState();
}

class _ButtonActiveCustomState extends State<ButtonActiveCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
