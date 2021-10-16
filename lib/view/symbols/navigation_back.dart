import 'package:flutter/material.dart';

class NavigationBack extends StatelessWidget {
  final constraints;

  NavigationBack(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/0_12075.png',
      width: constraints.maxWidth * 0.024,
      height: constraints.maxHeight * 0.243,
    );
  }
}
