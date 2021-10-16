import 'package:flutter/material.dart';

class AppleMacOSToggleSwitchOnDefault extends StatelessWidget {
  final constraints;

  AppleMacOSToggleSwitchOnDefault(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: constraints.maxWidth * 1.000,
        height: constraints.maxHeight * 0.967,
        child: Align(
          alignment: Alignment(0.00, 0.00),
          child: Stack(children: [
            Image.asset(
              'assets/images/0_12260.png',
              width: constraints.maxWidth * 1.000,
              height: constraints.maxHeight * 0.967,
            ),
            Image.asset(
              'assets/images/0_12259.png',
              width: constraints.maxWidth * 1.000,
              height: constraints.maxHeight * 0.967,
            ),
            Positioned(
              left: constraints.maxWidth * 0.431,
              right: constraints.maxWidth * 0.039,
              top: constraints.maxHeight * 0.062,
              bottom: constraints.maxHeight * 0.062,
              child: Image.asset(
                'assets/images/0_12261.png',
                width: constraints.maxWidth * 0.529,
                height: constraints.maxHeight * 0.842,
              ),
            ),
          ]),
        ));
  }
}
