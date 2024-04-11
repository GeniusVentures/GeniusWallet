import 'package:flutter/material.dart';

class PercentageCompletenessBarCustom extends StatefulWidget {
  final Widget? child;
  PercentageCompletenessBarCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _PercentageCompletenessBarCustomState createState() =>
      _PercentageCompletenessBarCustomState();
}

class _PercentageCompletenessBarCustomState
    extends State<PercentageCompletenessBarCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
