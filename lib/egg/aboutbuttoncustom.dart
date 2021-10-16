import 'package:flutter/material.dart';

class AboutButtonCustom extends StatefulWidget {
  final Widget child;
  AboutButtonCustom({Key key, this.child}) : super(key: key);

  @override
  _AboutButtonCustomState createState() => _AboutButtonCustomState();
}

class _AboutButtonCustomState extends State<AboutButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
