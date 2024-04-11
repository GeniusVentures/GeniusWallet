import 'package:flutter/material.dart';

class QRCodeCustom extends StatefulWidget {
  final Widget? child;
  QRCodeCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _QRCodeCustomState createState() => _QRCodeCustomState();
}

class _QRCodeCustomState extends State<QRCodeCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
