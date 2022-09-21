import 'package:flutter/material.dart';

class WhiteArrowCustom extends StatefulWidget {
  final Widget? child;
  WhiteArrowCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _WhiteArrowCustomState createState() => _WhiteArrowCustomState();
}

class _WhiteArrowCustomState extends State<WhiteArrowCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
