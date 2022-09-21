import 'package:flutter/material.dart';

class OptionsCustom extends StatefulWidget {
  final Widget? child;
  OptionsCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _OptionsCustomState createState() => _OptionsCustomState();
}

class _OptionsCustomState extends State<OptionsCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
