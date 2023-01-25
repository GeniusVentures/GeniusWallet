import 'package:flutter/material.dart';

class SendButtonCustom extends StatefulWidget {
  final Widget? child;
  SendButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _SendButtonCustomState createState() => _SendButtonCustomState();
}

class _SendButtonCustomState extends State<SendButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
