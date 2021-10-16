import 'package:flutter/material.dart';

class BackgroundDesktop extends StatelessWidget {
  final constraints;

  BackgroundDesktop(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/0_12573.png',
      width: constraints.maxWidth * 1.002,
      height: constraints.maxHeight * 0.938,
    );
  }
}
