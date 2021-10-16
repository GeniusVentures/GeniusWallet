import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  final Widget child;
  Menu({Key key, this.child}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
