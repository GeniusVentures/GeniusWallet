import 'package:flutter/material.dart';

class GnusAmountSelectorCustom extends StatefulWidget {
  final Widget child;
  GnusAmountSelectorCustom({Key key, this.child}) : super(key: key);

  @override
  _GnusAmountSelectorCustomState createState() =>
      _GnusAmountSelectorCustomState();
}

class _GnusAmountSelectorCustomState extends State<GnusAmountSelectorCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
