import 'package:flutter/material.dart';

class DecreaseCustom extends StatefulWidget {
  final Widget? child;
  DecreaseCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _DecreaseCustomState createState() => _DecreaseCustomState();
}

class _DecreaseCustomState extends State<DecreaseCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
