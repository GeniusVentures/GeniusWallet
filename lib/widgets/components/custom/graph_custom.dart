import 'package:flutter/material.dart';

class GraphCustom extends StatefulWidget {
  final Widget? child;
  GraphCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _GraphCustomState createState() => _GraphCustomState();
}

class _GraphCustomState extends State<GraphCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
