import 'package:flutter/material.dart';

class ProtocolSelectorCustom extends StatefulWidget {
  final Widget child;
  ProtocolSelectorCustom({Key key, this.child}) : super(key: key);

  @override
  _ProtocolSelectorCustomState createState() => _ProtocolSelectorCustomState();
}

class _ProtocolSelectorCustomState extends State<ProtocolSelectorCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
