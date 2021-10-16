import 'package:flutter/material.dart';

class Next extends StatefulWidget {
  final Widget child;
  Next({Key key, this.child}) : super(key: key);

  @override
  _NextState createState() => _NextState();
}

class _NextState extends State<Next> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
