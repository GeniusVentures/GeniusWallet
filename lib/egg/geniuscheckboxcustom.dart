import 'package:flutter/material.dart';

class GeniusCheckboxCustom extends StatefulWidget {
  final Widget child;
  GeniusCheckboxCustom({Key key, this.child}) : super(key: key);

  @override
  _GeniusCheckboxCustomState createState() => _GeniusCheckboxCustomState();
}

class _GeniusCheckboxCustomState extends State<GeniusCheckboxCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
