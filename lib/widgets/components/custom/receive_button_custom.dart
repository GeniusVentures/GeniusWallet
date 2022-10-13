import 'package:flutter/material.dart';

class ReceiveButtonCustom extends StatefulWidget {
  final Widget? child;
  ReceiveButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _ReceiveButtonCustomState createState() => _ReceiveButtonCustomState();
}

class _ReceiveButtonCustomState extends State<ReceiveButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
