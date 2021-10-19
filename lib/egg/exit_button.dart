import 'package:flutter/material.dart';

class ExitButton extends StatefulWidget {
  final Widget child;
  ExitButton({Key key, this.child}) : super(key: key);

  @override
  _ExitButtonState createState() => _ExitButtonState();
}

class _ExitButtonState extends State<ExitButton> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
