import 'package:flutter/material.dart';

class IsactiveTrueCustom extends StatefulWidget {
  final Widget? child;
  const IsactiveTrueCustom({
    super.key,
    this.child,
  });

  @override
  State<IsactiveTrueCustom> createState() => _IsactiveTrueCustomState();
}

class _IsactiveTrueCustomState extends State<IsactiveTrueCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
