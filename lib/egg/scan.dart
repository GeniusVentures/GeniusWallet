import 'package:flutter/material.dart';

class Scan extends StatefulWidget {
  final Widget child;
  Scan({Key key, this.child}) : super(key: key);

  @override
  _ScanState createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
