import 'package:flutter/material.dart';

class AlertsCustom extends StatefulWidget {
  final Widget? child;
  AlertsCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _AlertsCustomState createState() => _AlertsCustomState();
}

class _AlertsCustomState extends State<AlertsCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
