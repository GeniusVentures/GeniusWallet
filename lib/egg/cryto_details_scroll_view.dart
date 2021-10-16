import 'package:flutter/material.dart';

class CrytoDetailsScrollView extends StatefulWidget {
  final Widget child;
  CrytoDetailsScrollView({Key key, this.child}) : super(key: key);

  @override
  _CrytoDetailsScrollViewState createState() => _CrytoDetailsScrollViewState();
}

class _CrytoDetailsScrollViewState extends State<CrytoDetailsScrollView> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
