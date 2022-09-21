import 'package:flutter/material.dart';

class IncreaseCustom extends StatefulWidget {
  final Widget? child;
  IncreaseCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _IncreaseCustomState createState() => _IncreaseCustomState();
}

class _IncreaseCustomState extends State<IncreaseCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
