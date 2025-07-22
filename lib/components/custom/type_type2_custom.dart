import 'package:flutter/material.dart';

class TypeType2Custom extends StatefulWidget {
  final Widget? child;
  const TypeType2Custom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _TypeType2CustomState createState() => _TypeType2CustomState();
}

class _TypeType2CustomState extends State<TypeType2Custom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
