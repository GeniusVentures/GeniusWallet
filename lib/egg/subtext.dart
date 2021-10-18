import 'package:flutter/material.dart';

class Subtext extends StatefulWidget {
  final Widget child;
  Subtext({Key key, this.child}) : super(key: key);

  @override
  _SubtextState createState() => _SubtextState();
}

class _SubtextState extends State<Subtext> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
