import 'package:flutter/material.dart';

class IsactiveTrueCustom extends StatefulWidget {
  final Widget? child;
  IsactiveTrueCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _IsactiveTrueCustomState createState() => _IsactiveTrueCustomState();
}

class _IsactiveTrueCustomState extends State<IsactiveTrueCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
