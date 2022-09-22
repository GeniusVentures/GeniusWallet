import 'package:flutter/material.dart';

class PINMaskCustom extends StatefulWidget {
  final Widget? child;
  PINMaskCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _PINMaskCustomState createState() => _PINMaskCustomState();
}

class _PINMaskCustomState extends State<PINMaskCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
