import 'package:flutter/material.dart';

class ContractIcon extends StatelessWidget {
  final constraints;

  ContractIcon(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/0_12503.png',
      width: constraints.maxWidth * 1.000,
      height: constraints.maxHeight * 1.000,
    );
  }
}
