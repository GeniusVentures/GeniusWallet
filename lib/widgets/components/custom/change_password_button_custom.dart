import 'package:flutter/material.dart';

class ChangePasswordButtonCustom extends StatefulWidget {
  final Widget? child;
  const ChangePasswordButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _ChangePasswordButtonCustomState createState() =>
      _ChangePasswordButtonCustomState();
}

class _ChangePasswordButtonCustomState
    extends State<ChangePasswordButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
