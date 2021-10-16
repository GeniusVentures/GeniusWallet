import 'package:flutter/material.dart';

class ApplemacOSToggleSwitchOnDefault extends StatelessWidget {
  final constraints;
  final ovrMask;
  final ovrMask2;
  final ovrknob;
  ApplemacOSToggleSwitchOnDefault(
    this.constraints, {
    Key key,
    this.ovrMask,
    this.ovrMask2,
    this.ovrknob,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: 0,
        width: constraints.maxWidth * 1.0,
        top: 0,
        height: constraints.maxHeight * 0.967,
        child: Image.asset(
          ovrMask ?? 'assets/images/0_12260.png',
          width: constraints.maxWidth * 35.000,
          height: constraints.maxHeight * 21.275,
        ),
      ),
      Positioned(
        left: 0,
        width: constraints.maxWidth * 1.0,
        top: 0,
        height: constraints.maxHeight * 0.967,
        child: Image.asset(
          ovrMask2 ?? 'assets/images/0_12259.png',
          width: constraints.maxWidth * 35.000,
          height: constraints.maxHeight * 21.275,
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.431,
        width: constraints.maxWidth * 0.529,
        top: constraints.maxHeight * 0.062,
        height: constraints.maxHeight * 0.842,
        child: Image.asset(
          ovrknob ?? 'assets/images/0_12261.png',
          width: constraints.maxWidth * 18.529,
          height: constraints.maxHeight * 18.529,
        ),
      ),
    ]);
  }
}
