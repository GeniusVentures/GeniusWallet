import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class DoubleInfoDesktop extends StatelessWidget {
  final constraints;
  final ovrRectangle2;
  final ovrTypesomething;
  final ovrTypesomethingCopy;
  DoubleInfoDesktop(
    this.constraints, {
    Key key,
    this.ovrRectangle2,
    this.ovrTypesomething,
    this.ovrTypesomethingCopy,
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
          width: constraints.maxWidth * 385.000,
          height: constraints.maxHeight * 71.000,
          decoration: BoxDecoration(
            color: Color(0xff003698),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
      Positioned(
        right: 8.0,
        width: 4.5,
        top: constraints.maxHeight * 0.43,
        height: constraints.maxHeight * 0.063,
        child: Center(
            child: Container(
                height: 4.5,
                child: Image.asset(
                  'assets/images/206_3649.png',
                  width: constraints.maxWidth * 4.500,
                  height: constraints.maxHeight * 4.500,
                ))),
      ),
      Positioned(
        left: 9.0,
        width: 60.0,
        top: constraints.maxHeight * 0.085,
        height: constraints.maxHeight * 0.845,
        child: Center(
            child: Container(
                height: 60.0,
                child: Image.asset(
                  ovrRectangle2 ?? 'assets/images/206_3652.png',
                  width: constraints.maxWidth * 60.000,
                  height: constraints.maxHeight * 60.000,
                ))),
      ),
      Positioned(
        left: 96.0,
        width: 269.0,
        top: constraints.maxHeight * 0.042,
        height: constraints.maxHeight * 0.465,
        child: Center(
            child: Container(
                height: 33.0,
                child: Container(
                    width: constraints.maxWidth * 269.000,
                    height: constraints.maxHeight * 33.000,
                    child: AutoSizeText(
                      ovrTypesomething ?? 'Type something',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 24.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )))),
      ),
      Positioned(
        left: 96.0,
        right: 101.0,
        top: constraints.maxHeight * 0.521,
        height: constraints.maxHeight * 0.423,
        child: Center(
            child: Container(
                height: 30.0,
                child: Container(
                    width: constraints.maxWidth * 188.000,
                    height: constraints.maxHeight * 30.000,
                    child: AutoSizeText(
                      ovrTypesomethingCopy ?? 'Type something',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 18.0,
                        fontWeight: FontWeight.w100,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )))),
      ),
    ]);
  }
}
