import 'package:flutter/material.dart';

class TextInputCopyCustom extends StatefulWidget {
  final Widget child;
  TextInputCopyCustom({Key key, this.child}) : super(key: key);

  @override
  _TextInputCopyCustomState createState() => _TextInputCopyCustomState();
}

class _TextInputCopyCustomState extends State<TextInputCopyCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
