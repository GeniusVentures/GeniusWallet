import 'package:flutter/material.dart';

class GeniusCloseButtonCustom extends StatefulWidget {
  final Widget? child;
  GeniusCloseButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _GeniusCloseButtonCustomState createState() =>
      _GeniusCloseButtonCustomState();
}

class _GeniusCloseButtonCustomState extends State<GeniusCloseButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
