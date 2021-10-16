import 'package:flutter/material.dart';

class BackArrow extends StatefulWidget {
  final Widget child;
  BackArrow({Key key, this.child}) : super(key: key);

  @override
  _BackArrowState createState() => _BackArrowState();
}

class _BackArrowState extends State<BackArrow> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
