import 'package:flutter/material.dart';

class MarkPriceCustom extends StatefulWidget {
  final Widget? child;
  MarkPriceCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _MarkPriceCustomState createState() => _MarkPriceCustomState();
}

class _MarkPriceCustomState extends State<MarkPriceCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
