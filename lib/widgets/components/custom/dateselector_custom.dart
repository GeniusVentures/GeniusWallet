import 'package:flutter/material.dart';

class DateselectorCustom extends StatefulWidget {
  final Widget? child;
  DateselectorCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _DateselectorCustomState createState() => _DateselectorCustomState();
}

class _DateselectorCustomState extends State<DateselectorCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
