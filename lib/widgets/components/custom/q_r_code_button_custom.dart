import 'package:flutter/material.dart';

class QRCodeButtonCustom extends StatefulWidget {
  final Widget? child;
  QRCodeButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _QRCodeButtonCustomState createState() => _QRCodeButtonCustomState();
}

class _QRCodeButtonCustomState extends State<QRCodeButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
