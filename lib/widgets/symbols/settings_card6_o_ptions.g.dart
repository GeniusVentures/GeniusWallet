import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class SettingsCard6OPtions extends StatelessWidget {
  final constraints;
  final ovrTypesomething;
  final ovrRectangle2;
  final ovrTypesomething2;
  final ovrRectangle22;
  final ovrTypesomething3;
  final ovrRectangle23;
  final ovrTypesomething4;
  final ovrRectangle24;
  final ovrTypesomething5;
  final ovrRectangle25;
  final ovrTypesomething6;
  final ovrRectangle26;
  final ovrLineCopy2;
  final ovrLineCopy3;
  final ovrLineCopy4;
  final ovrLineCopy5;
  final ovrLineCopy6;
  SettingsCard6OPtions(
    this.constraints, {
    Key key,
    this.ovrTypesomething,
    this.ovrRectangle2,
    this.ovrTypesomething2,
    this.ovrRectangle22,
    this.ovrTypesomething3,
    this.ovrRectangle23,
    this.ovrTypesomething4,
    this.ovrRectangle24,
    this.ovrTypesomething5,
    this.ovrRectangle25,
    this.ovrTypesomething6,
    this.ovrRectangle26,
    this.ovrLineCopy2,
    this.ovrLineCopy3,
    this.ovrLineCopy4,
    this.ovrLineCopy5,
    this.ovrLineCopy6,
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
          height: constraints.maxHeight * 270.000,
          decoration: BoxDecoration(
            color: Color(0xff003698),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
      Positioned(
        left: 6.0,
        right: 8.0,
        top: constraints.maxHeight * 0.019,
        height: constraints.maxHeight * 0.13,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.955,
            top: 0,
            height: constraints.maxHeight * 0.13,
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
              'assets/images/0_12313.png',
              width: constraints.maxWidth * 4.500,
              height: constraints.maxHeight * 4.500,
            ),
          ),
          Positioned(
            left: 0,
            width: 35.0,
            top: 0,
            height: 35.0,
            child: Image.asset(
              ovrRectangle2 ?? 'assets/images/0_12316.png',
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
        left: 6.0,
        right: 8.0,
        top: constraints.maxHeight * 0.185,
        height: constraints.maxHeight * 0.13,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.955,
            top: 0,
            height: constraints.maxHeight * 0.13,
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
              'assets/images/0_12319.png',
              width: constraints.maxWidth * 4.500,
              height: constraints.maxHeight * 4.500,
            ),
          ),
          Positioned(
            left: 0,
            width: 35.0,
            top: 0,
            height: 35.0,
            child: Image.asset(
              ovrRectangle22 ?? 'assets/images/0_12322.png',
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
        left: 6.0,
        right: 8.0,
        top: constraints.maxHeight * 0.352,
        height: constraints.maxHeight * 0.13,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.955,
            top: 0,
            height: constraints.maxHeight * 0.13,
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
              'assets/images/0_12325.png',
              width: constraints.maxWidth * 4.500,
              height: constraints.maxHeight * 4.500,
            ),
          ),
          Positioned(
            left: 0,
            width: 35.0,
            top: 0,
            height: 35.0,
            child: Image.asset(
              ovrRectangle23 ?? 'assets/images/0_12328.png',
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
        left: 6.0,
        right: 8.0,
        top: constraints.maxHeight * 0.519,
        height: constraints.maxHeight * 0.13,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.955,
            top: 0,
            height: constraints.maxHeight * 0.13,
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
              'assets/images/0_12331.png',
              width: constraints.maxWidth * 4.500,
              height: constraints.maxHeight * 4.500,
            ),
          ),
          Positioned(
            left: 0,
            width: 35.0,
            top: 0,
            height: 35.0,
            child: Image.asset(
              ovrRectangle24 ?? 'assets/images/0_12334.png',
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
                  ovrTypesomething4 ?? 'Type something',
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
        left: 6.0,
        right: 8.0,
        top: constraints.maxHeight * 0.685,
        height: constraints.maxHeight * 0.13,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.955,
            top: 0,
            height: constraints.maxHeight * 0.13,
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
              'assets/images/0_12337.png',
              width: constraints.maxWidth * 4.500,
              height: constraints.maxHeight * 4.500,
            ),
          ),
          Positioned(
            left: 0,
            width: 35.0,
            top: 0,
            height: 35.0,
            child: Image.asset(
              ovrRectangle25 ?? 'assets/images/0_12340.png',
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
                  ovrTypesomething5 ?? 'Type something',
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
        left: 6.0,
        right: 8.0,
        top: constraints.maxHeight * 0.852,
        height: constraints.maxHeight * 0.13,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.955,
            top: 0,
            height: constraints.maxHeight * 0.13,
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
              'assets/images/0_12343.png',
              width: constraints.maxWidth * 4.500,
              height: constraints.maxHeight * 4.500,
            ),
          ),
          Positioned(
            left: 0,
            width: 35.0,
            top: 0,
            height: 35.0,
            child: Image.asset(
              ovrRectangle26 ?? 'assets/images/0_12346.png',
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
                  ovrTypesomething6 ?? 'Type something',
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
        left: 48.0,
        right: 8.0,
        top: constraints.maxHeight * 0.167,
        height: constraints.maxHeight * 0.007,
        child: Image.asset(
          ovrLineCopy2 ?? 'assets/images/0_12348.png',
          width: constraints.maxWidth * 254.000,
          height: constraints.maxHeight * 2.000,
        ),
      ),
      Positioned(
        left: 48.0,
        right: 8.0,
        top: constraints.maxHeight * 0.326,
        height: constraints.maxHeight * 0.007,
        child: Image.asset(
          ovrLineCopy3 ?? 'assets/images/0_12349.png',
          width: constraints.maxWidth * 254.000,
          height: constraints.maxHeight * 2.000,
        ),
      ),
      Positioned(
        left: 48.0,
        right: 8.0,
        top: constraints.maxHeight * 0.5,
        height: constraints.maxHeight * 0.007,
        child: Image.asset(
          ovrLineCopy4 ?? 'assets/images/0_12350.png',
          width: constraints.maxWidth * 254.000,
          height: constraints.maxHeight * 2.000,
        ),
      ),
      Positioned(
        left: 48.0,
        right: 8.0,
        top: constraints.maxHeight * 0.659,
        height: constraints.maxHeight * 0.007,
        child: Image.asset(
          ovrLineCopy5 ?? 'assets/images/0_12351.png',
          width: constraints.maxWidth * 254.000,
          height: constraints.maxHeight * 2.000,
        ),
      ),
      Positioned(
        left: 48.0,
        right: 8.0,
        top: constraints.maxHeight * 0.833,
        height: constraints.maxHeight * 0.007,
        child: Image.asset(
          ovrLineCopy6 ?? 'assets/images/0_12352.png',
          width: constraints.maxWidth * 254.000,
          height: constraints.maxHeight * 2.000,
        ),
      ),
    ]);
  }
}
