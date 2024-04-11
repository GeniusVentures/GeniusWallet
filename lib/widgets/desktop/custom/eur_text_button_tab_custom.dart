import 'package:flutter/material.dart';

class EurTextButtonTabCustom extends StatefulWidget {
  final Widget? child;
  EurTextButtonTabCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _EurTextButtonTabCustomState createState() => _EurTextButtonTabCustomState();
}

class _EurTextButtonTabCustomState extends State<EurTextButtonTabCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
