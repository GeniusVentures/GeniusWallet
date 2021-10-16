import 'package:flutter/material.dart';

class BackgroundMobile extends StatelessWidget {
  final constraints;

  BackgroundMobile(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/121_4537.png',
      width: constraints.maxWidth * 375.000,
      height: constraints.maxHeight * 718.000,
    );
  }
}
