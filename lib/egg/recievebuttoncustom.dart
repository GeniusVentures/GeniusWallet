import 'package:flutter/material.dart';

class RecieveButtonCustom extends StatefulWidget {
  final Widget child;
  RecieveButtonCustom({Key key, this.child}) : super(key: key);

  @override
  _RecieveButtonCustomState createState() => _RecieveButtonCustomState();
}

class _RecieveButtonCustomState extends State<RecieveButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
