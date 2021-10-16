import 'package:flutter/material.dart';

class GeniusScreenshot extends StatelessWidget {
  final constraints;
  final ovrScreenShot20210813at12809PM;
  GeniusScreenshot(
    this.constraints, {
    Key key,
    this.ovrScreenShot20210813at12809PM,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      ovrScreenShot20210813at12809PM ?? 'assets/images/0_12481.png',
      width: constraints.maxWidth * 165.000,
      height: constraints.maxHeight * 159.492,
    );
  }
}
