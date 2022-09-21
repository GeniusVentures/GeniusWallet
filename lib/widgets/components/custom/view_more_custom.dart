import 'package:flutter/material.dart';

class ViewMoreCustom extends StatefulWidget {
  final Widget? child;
  ViewMoreCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _ViewMoreCustomState createState() => _ViewMoreCustomState();
}

class _ViewMoreCustomState extends State<ViewMoreCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
