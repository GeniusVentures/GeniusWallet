import 'package:flutter/material.dart';

class PointingRightCustom extends StatefulWidget {
  final Widget? child;
  PointingRightCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _PointingRightCustomState createState() => _PointingRightCustomState();
}

class _PointingRightCustomState extends State<PointingRightCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
