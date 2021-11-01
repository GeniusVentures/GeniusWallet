import 'package:flutter/material.dart';

class GeniusIcon extends StatelessWidget {
  final constraints;
  final ovrEllipse3;
  GeniusIcon(
    this.constraints, {
    Key key,
    this.ovrEllipse3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ovrEllipse3 ??
        Image.asset(
          'assets/images/0_12263.png',
          width: constraints.maxWidth * 77.100,
          height: constraints.maxHeight * 77.100,
        );
  }
}
