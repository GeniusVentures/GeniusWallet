import 'package:flutter/material.dart';

class TextInputCustom extends StatefulWidget {
  final Widget child;
  TextInputCustom({Key key, this.child}) : super(key: key);

  @override
  _TextInputCustomState createState() => _TextInputCustomState();
}

class _TextInputCustomState extends State<TextInputCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
