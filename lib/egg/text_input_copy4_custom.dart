import 'package:flutter/material.dart';

class TextInputCopy4Custom extends StatefulWidget {
  final Widget child;
  TextInputCopy4Custom({Key key, this.child}) : super(key: key);

  @override
  _TextInputCopy4CustomState createState() => _TextInputCopy4CustomState();
}

class _TextInputCopy4CustomState extends State<TextInputCopy4Custom> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
