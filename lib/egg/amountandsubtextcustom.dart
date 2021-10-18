import 'package:flutter/material.dart';

class AmountAndSubtextCustom extends StatefulWidget {
  final Widget child;
  AmountAndSubtextCustom({Key key, this.child}) : super(key: key);

  @override
  _AmountAndSubtextCustomState createState() => _AmountAndSubtextCustomState();
}

class _AmountAndSubtextCustomState extends State<AmountAndSubtextCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
