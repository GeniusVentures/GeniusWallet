import 'package:flutter/material.dart';

class IsactiveFalseCustom extends StatefulWidget {
  final Widget? child;
  IsactiveFalseCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _IsactiveFalseCustomState createState() => _IsactiveFalseCustomState();
}

class _IsactiveFalseCustomState extends State<IsactiveFalseCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
