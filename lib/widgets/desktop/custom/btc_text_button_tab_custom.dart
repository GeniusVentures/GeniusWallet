import 'package:flutter/material.dart';

class BtcTextButtonTabCustom extends StatefulWidget {
  final Widget? child;
  BtcTextButtonTabCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _BtcTextButtonTabCustomState createState() => _BtcTextButtonTabCustomState();
}

class _BtcTextButtonTabCustomState extends State<BtcTextButtonTabCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
