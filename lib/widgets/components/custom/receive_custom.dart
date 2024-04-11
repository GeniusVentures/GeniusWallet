import 'package:flutter/material.dart';

class ReceiveCustom extends StatefulWidget {
  final Widget? child;
  ReceiveCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _ReceiveCustomState createState() => _ReceiveCustomState();
}

class _ReceiveCustomState extends State<ReceiveCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
