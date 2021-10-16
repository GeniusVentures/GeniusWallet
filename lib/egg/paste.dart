import 'package:flutter/material.dart';

class Paste extends StatefulWidget {
  final Widget child;
  Paste({Key key, this.child}) : super(key: key);

  @override
  _PasteState createState() => _PasteState();
}

class _PasteState extends State<Paste> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
