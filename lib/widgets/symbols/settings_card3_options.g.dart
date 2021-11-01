import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class SettingsCard3Options extends StatelessWidget {
  final constraints;
  final ovrTypesomething;
  final ovrRectangle2;
  final ovrTypesomething2;
  final ovrRectangle22;
  final ovrTypesomething3;
  final ovrRectangle23;
  final ovrLine4;
  final ovrLineCopy;
  SettingsCard3Options(
    this.constraints, {
    Key key,
    this.ovrTypesomething,
    this.ovrRectangle2,
    this.ovrTypesomething2,
    this.ovrRectangle22,
    this.ovrTypesomething3,
    this.ovrRectangle23,
    this.ovrLine4,
    this.ovrLineCopy,
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
          height: constraints.maxHeight * 135.000,
          decoration: BoxDecoration(
            color: Color(0xff003698),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.019,
        width: constraints.maxWidth * 0.955,
        top: constraints.maxHeight * 0.037,
        height: constraints.maxHeight * 0.259,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.955,
            top: 0,
            height: constraints.maxHeight * 0.259,
            child: Container(
              width: constraints.maxWidth * 296.000,
              height: constraints.maxHeight * 35.000,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
          Positioned(
            right: 0,
            width: 4.5,
            top: 12.5,
            height: 4.5,
            child: Image.asset(
              'assets/images/0_12291.png',
              width: constraints.maxWidth * 4.500,
              height: constraints.maxHeight * 4.500,
            ),
          ),
          Positioned(
            left: 0,
            width: 35.0,
            top: 0,
            height: 35.0,
            child: ovrRectangle2 ??
                Image.asset(
                  'assets/images/0_12294.png',
                  width: constraints.maxWidth * 35.000,
                  height: constraints.maxHeight * 35.000,
                ),
          ),
          Positioned(
            left: 42.0,
            right: 16.0,
            top: 7.0,
            bottom: 6.0,
            child: Container(
                width: constraints.maxWidth * 238.000,
                height: constraints.maxHeight * 22.000,
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
        ]),
      ),
      Positioned(
        left: constraints.maxWidth * 0.019,
        width: constraints.maxWidth * 0.955,
        top: constraints.maxHeight * 0.37,
        height: constraints.maxHeight * 0.259,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.955,
            top: 0,
            height: constraints.maxHeight * 0.259,
            child: Container(
              width: constraints.maxWidth * 296.000,
              height: constraints.maxHeight * 35.000,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
          Positioned(
            right: 0,
            width: 4.5,
            top: 12.5,
            height: 4.5,
            child: Image.asset(
              'assets/images/0_12297.png',
              width: constraints.maxWidth * 4.500,
              height: constraints.maxHeight * 4.500,
            ),
          ),
          Positioned(
            left: 0,
            width: 35.0,
            top: 0,
            height: 35.0,
            child: ovrRectangle22 ??
                Image.asset(
                  'assets/images/0_12300.png',
                  width: constraints.maxWidth * 35.000,
                  height: constraints.maxHeight * 35.000,
                ),
          ),
          Positioned(
            left: 42.0,
            right: 16.0,
            top: 7.0,
            bottom: 6.0,
            child: Container(
                width: constraints.maxWidth * 238.000,
                height: constraints.maxHeight * 22.000,
                child: AutoSizeText(
                  ovrTypesomething2 ?? 'Type something',
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
        ]),
      ),
      Positioned(
        left: constraints.maxWidth * 0.019,
        width: constraints.maxWidth * 0.955,
        top: constraints.maxHeight * 0.704,
        height: constraints.maxHeight * 0.259,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.955,
            top: 0,
            height: constraints.maxHeight * 0.259,
            child: Container(
              width: constraints.maxWidth * 296.000,
              height: constraints.maxHeight * 35.000,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
          Positioned(
            right: 0,
            width: 4.5,
            top: 12.5,
            height: 4.5,
            child: Image.asset(
              'assets/images/0_12303.png',
              width: constraints.maxWidth * 4.500,
              height: constraints.maxHeight * 4.500,
            ),
          ),
          Positioned(
            left: 0,
            width: 35.0,
            top: 0,
            height: 35.0,
            child: ovrRectangle23 ??
                Image.asset(
                  'assets/images/0_12306.png',
                  width: constraints.maxWidth * 35.000,
                  height: constraints.maxHeight * 35.000,
                ),
          ),
          Positioned(
            left: 42.0,
            right: 16.0,
            top: 7.0,
            bottom: 6.0,
            child: Container(
                width: constraints.maxWidth * 238.000,
                height: constraints.maxHeight * 22.000,
                child: AutoSizeText(
                  ovrTypesomething3 ?? 'Type something',
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
        ]),
      ),
      Positioned(
        left: 49.0,
        right: 7.0,
        top: constraints.maxHeight * 0.322,
        height: constraints.maxHeight * 0.015,
        child: ovrLine4 ??
            Image.asset(
              'assets/images/0_12308.png',
              width: constraints.maxWidth * 254.000,
              height: constraints.maxHeight * 2.000,
            ),
      ),
      Positioned(
        left: 49.0,
        right: 7.0,
        top: constraints.maxHeight * 0.663,
        height: constraints.maxHeight * 0.015,
        child: ovrLineCopy ??
            Image.asset(
              'assets/images/0_12309.png',
              width: constraints.maxWidth * 254.000,
              height: constraints.maxHeight * 2.000,
            ),
      ),
    ]);
  }
}
