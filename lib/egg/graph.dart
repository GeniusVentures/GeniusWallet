import 'package:flutter/material.dart';

class Graph extends StatefulWidget {
  final Widget child;
  Graph({Key key, this.child}) : super(key: key);

  @override
  _GraphState createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
