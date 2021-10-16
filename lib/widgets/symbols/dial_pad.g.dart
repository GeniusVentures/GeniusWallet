import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class DialPad extends StatelessWidget {
  final constraints;
  final ovr9;
  final ovr0;
  final ovr;
  final ovr8;
  final ovr7;
  final ovr6;
  final ovr5;
  final ovr4;
  final ovr3;
  final ovr2;
  final ovr1;
  DialPad(
    this.constraints, {
    Key key,
    this.ovr9,
    this.ovr0,
    this.ovr,
    this.ovr8,
    this.ovr7,
    this.ovr6,
    this.ovr5,
    this.ovr4,
    this.ovr3,
    this.ovr2,
    this.ovr1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: constraints.maxWidth * 0.002,
        width: constraints.maxWidth * 1.0,
        top: 0,
        height: constraints.maxHeight * 1.0,
        child: Container(
          width: constraints.maxWidth * 248.500,
          height: constraints.maxHeight * 306.000,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.013,
        width: constraints.maxWidth * 0.056,
        top: 0,
        height: constraints.maxHeight * 0.176,
        child: Container(
            width: constraints.maxWidth * 14.000,
            height: constraints.maxHeight * 54.000,
            child: AutoSizeText(
              ovr1 ?? '1',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 36.0,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
      Positioned(
        left: constraints.maxWidth * 0.456,
        width: constraints.maxWidth * 0.085,
        top: 0,
        height: constraints.maxHeight * 0.176,
        child: Container(
            width: constraints.maxWidth * 21.000,
            height: constraints.maxHeight * 54.000,
            child: AutoSizeText(
              ovr2 ?? '2',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 36.0,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
      Positioned(
        right: 0,
        width: 36.341,
        top: 269.0,
        height: 27.0,
        child: Image.asset(
          'assets/images/166_1884.png',
          width: constraints.maxWidth * 36.341,
          height: constraints.maxHeight * 27.000,
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.91,
        width: constraints.maxWidth * 0.085,
        top: 0,
        height: constraints.maxHeight * 0.176,
        child: Container(
            width: constraints.maxWidth * 21.000,
            height: constraints.maxHeight * 54.000,
            child: AutoSizeText(
              ovr3 ?? '3',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 36.0,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
      Positioned(
        left: 0,
        width: constraints.maxWidth * 0.093,
        top: constraints.maxHeight * 0.275,
        height: constraints.maxHeight * 0.176,
        child: Container(
            width: constraints.maxWidth * 23.000,
            height: constraints.maxHeight * 54.000,
            child: AutoSizeText(
              ovr4 ?? '4',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 36.0,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
      Positioned(
        left: constraints.maxWidth * 0.459,
        width: constraints.maxWidth * 0.085,
        top: constraints.maxHeight * 0.275,
        height: constraints.maxHeight * 0.176,
        child: Container(
            width: constraints.maxWidth * 21.000,
            height: constraints.maxHeight * 54.000,
            child: AutoSizeText(
              ovr5 ?? '5',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 36.0,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
      Positioned(
        left: constraints.maxWidth * 0.909,
        width: constraints.maxWidth * 0.093,
        top: constraints.maxHeight * 0.275,
        height: constraints.maxHeight * 0.176,
        child: Container(
            width: constraints.maxWidth * 23.000,
            height: constraints.maxHeight * 54.000,
            child: AutoSizeText(
              ovr6 ?? '6',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 36.0,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
      Positioned(
        left: constraints.maxWidth * 0.002,
        width: constraints.maxWidth * 0.08,
        top: constraints.maxHeight * 0.549,
        height: constraints.maxHeight * 0.176,
        child: Container(
            width: constraints.maxWidth * 20.000,
            height: constraints.maxHeight * 54.000,
            child: AutoSizeText(
              ovr7 ?? '7',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 36.0,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
      Positioned(
        left: constraints.maxWidth * 0.451,
        width: constraints.maxWidth * 0.093,
        top: constraints.maxHeight * 0.549,
        height: constraints.maxHeight * 0.176,
        child: Container(
            width: constraints.maxWidth * 23.000,
            height: constraints.maxHeight * 54.000,
            child: AutoSizeText(
              ovr8 ?? '8',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 36.0,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
      Positioned(
        left: constraints.maxWidth * 0.029,
        width: constraints.maxWidth * 0.028,
        top: constraints.maxHeight * 0.824,
        height: constraints.maxHeight * 0.176,
        child: Container(
            width: constraints.maxWidth * 7.000,
            height: constraints.maxHeight * 54.000,
            child: AutoSizeText(
              ovr ?? '.',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 36.0,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
      Positioned(
        left: constraints.maxWidth * 0.447,
        width: constraints.maxWidth * 0.101,
        top: constraints.maxHeight * 0.824,
        height: constraints.maxHeight * 0.176,
        child: Container(
            width: constraints.maxWidth * 25.000,
            height: constraints.maxHeight * 54.000,
            child: AutoSizeText(
              ovr0 ?? '0',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 36.0,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
      Positioned(
        left: constraints.maxWidth * 0.907,
        width: constraints.maxWidth * 0.093,
        top: constraints.maxHeight * 0.549,
        height: constraints.maxHeight * 0.176,
        child: Container(
            width: constraints.maxWidth * 23.000,
            height: constraints.maxHeight * 54.000,
            child: AutoSizeText(
              ovr9 ?? '9',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 36.0,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
    ]);
  }
}
