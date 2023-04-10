import 'package:flutter/material.dart';

class NavNewsButtonCustom extends StatefulWidget {
  final Widget? child;
  NavNewsButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _NavNewsButtonCustomState createState() => _NavNewsButtonCustomState();
}

class _NavNewsButtonCustomState extends State<NavNewsButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
