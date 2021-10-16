import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class SettingsCard extends StatelessWidget {
  final constraints;
  final ovrRectangle2;
  final ovrTypesomething;
  SettingsCard(
    this.constraints, {
    Key key,
    this.ovrRectangle2,
    this.ovrTypesomething,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: Container(
          width: constraints.maxWidth * 310.000,
          height: constraints.maxHeight * 45.000,
          decoration: BoxDecoration(
            color: Color(0xff003698),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
      Positioned(
        right: 8.0,
        width: 4.5,
        top: constraints.maxHeight * 0.389,
        height: constraints.maxHeight * 0.1,
        child: Center(
            child: Container(
                height: 4.5,
                child: Image.asset(
                  'assets/images/0_12269.png',
                  width: constraints.maxWidth * 4.500,
                  height: constraints.maxHeight * 4.500,
                ))),
      ),
      Positioned(
        left: 6.0,
        width: 35.0,
        top: constraints.maxHeight * 0.111,
        height: constraints.maxHeight * 0.778,
        child: Center(
            child: Container(
                height: 35.0,
                child: Image.asset(
                  ovrRectangle2 ?? 'assets/images/0_12272.png',
                  width: constraints.maxWidth * 35.000,
                  height: constraints.maxHeight * 35.000,
                ))),
      ),
      Positioned(
        left: 48.0,
        width: 238.0,
        top: 12.0,
        bottom: 12.0,
        child: Container(
            width: constraints.maxWidth * 238.000,
            height: constraints.maxHeight * 21.000,
            child: AutoSizeText(
              ovrTypesomething ?? 'Type something',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.left,
            )),
      ),
    ]);
  }
}
