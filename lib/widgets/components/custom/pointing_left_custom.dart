import 'package:flutter/material.dart';

class PointingLeftCustom extends StatefulWidget {
  final Widget? child;
  PointingLeftCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _PointingLeftCustomState createState() => _PointingLeftCustomState();
}

class _PointingLeftCustomState extends State<PointingLeftCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
