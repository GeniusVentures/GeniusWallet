import 'package:flutter/material.dart';

class PercentageCompletenessTextCustom extends StatefulWidget {
  final Widget? child;
  PercentageCompletenessTextCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _PercentageCompletenessTextCustomState createState() =>
      _PercentageCompletenessTextCustomState();
}

class _PercentageCompletenessTextCustomState
    extends State<PercentageCompletenessTextCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
