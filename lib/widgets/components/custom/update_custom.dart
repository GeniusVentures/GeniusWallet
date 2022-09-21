import 'package:flutter/material.dart';

class UpdateCustom extends StatefulWidget {
  final Widget? child;
  UpdateCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _UpdateCustomState createState() => _UpdateCustomState();
}

class _UpdateCustomState extends State<UpdateCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
