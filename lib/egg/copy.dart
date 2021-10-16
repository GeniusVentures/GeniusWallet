import 'package:flutter/material.dart';

class Copy extends StatefulWidget {
  final Widget child;
  Copy({Key key, this.child}) : super(key: key);

  @override
  _CopyState createState() => _CopyState();
}

class _CopyState extends State<Copy> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
