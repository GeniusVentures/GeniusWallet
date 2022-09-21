import 'package:flutter/material.dart';

class TypeCreateCustom extends StatefulWidget {
  final Widget? child;
  TypeCreateCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _TypeCreateCustomState createState() => _TypeCreateCustomState();
}

class _TypeCreateCustomState extends State<TypeCreateCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
