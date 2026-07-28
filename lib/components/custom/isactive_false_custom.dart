import 'package:flutter/material.dart';

class IsactiveFalseCustom extends StatefulWidget {
  final Widget? child;
  const IsactiveFalseCustom({super.key, this.child});

  @override
  _IsactiveFalseCustomState createState() => _IsactiveFalseCustomState();
}

class _IsactiveFalseCustomState extends State<IsactiveFalseCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
