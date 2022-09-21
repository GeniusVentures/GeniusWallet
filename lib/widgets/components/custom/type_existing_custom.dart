import 'package:flutter/material.dart';

class TypeExistingCustom extends StatefulWidget {
  final Widget? child;
  TypeExistingCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _TypeExistingCustomState createState() => _TypeExistingCustomState();
}

class _TypeExistingCustomState extends State<TypeExistingCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
