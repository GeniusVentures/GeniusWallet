import 'package:flutter/material.dart';

class PriceAlertsCustom extends StatefulWidget {
  final Widget child;
  PriceAlertsCustom({Key key, this.child}) : super(key: key);

  @override
  _PriceAlertsCustomState createState() => _PriceAlertsCustomState();
}

class _PriceAlertsCustomState extends State<PriceAlertsCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
