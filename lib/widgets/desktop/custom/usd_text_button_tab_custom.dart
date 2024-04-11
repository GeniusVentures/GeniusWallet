import 'package:flutter/material.dart';

class UsdTextButtonTabCustom extends StatefulWidget {
  final Widget? child;
  UsdTextButtonTabCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _UsdTextButtonTabCustomState createState() => _UsdTextButtonTabCustomState();
}

class _UsdTextButtonTabCustomState extends State<UsdTextButtonTabCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
