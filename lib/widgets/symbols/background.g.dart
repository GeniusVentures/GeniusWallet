import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final constraints;

  Background(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/0_12361.png',
      width: constraints.maxWidth * 744.682,
      height: constraints.maxHeight * 718.491,
    );
  }
}
