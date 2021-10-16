import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class GeniusSlider extends StatelessWidget {
  final constraints;
  final ovrType;
  final ovrTypeCopy3;
  final ovrTypeCopy;
  final ovrTypeCopy2;
  final ovrEllipse;
  final ovrLine;
  final ovrLineCopy;
  GeniusSlider(
    this.constraints, {
    Key key,
    this.ovrType,
    this.ovrTypeCopy3,
    this.ovrTypeCopy,
    this.ovrTypeCopy2,
    this.ovrEllipse,
    this.ovrLine,
    this.ovrLineCopy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: 0,
        right: 19.0,
        top: 0,
        height: 27.0,
        child: Container(
            width: constraints.maxWidth * 291.000,
            height: constraints.maxHeight * 27.000,
            child: AutoSizeText(
              ovrType ?? 'Type',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.left,
            )),
      ),
      Positioned(
        left: 133.5,
        right: 134.5,
        top: 57.0,
        bottom: 0,
        child: Container(
            width: constraints.maxWidth * 42.000,
            height: constraints.maxHeight * 27.000,
            child: AutoSizeText(
              ovrTypeCopy3 ?? 'Type',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
      Positioned(
        left: 0,
        width: 23.0,
        top: constraints.maxHeight * 0.762,
        height: constraints.maxHeight * 0.183,
        child: Container(
            width: constraints.maxWidth * 23.000,
            height: constraints.maxHeight * 15.000,
            child: AutoSizeText(
              ovrTypeCopy ?? 'Type',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 10.0,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.left,
            )),
      ),
      Positioned(
        right: 0,
        width: 23.0,
        top: constraints.maxHeight * 0.762,
        height: constraints.maxHeight * 0.183,
        child: Container(
            width: constraints.maxWidth * 23.000,
            height: constraints.maxHeight * 15.000,
            child: AutoSizeText(
              ovrTypeCopy2 ?? 'Type',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 10.0,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.right,
            )),
      ),
      Positioned(
        left: 0,
        right: 0,
        top: 44.0,
        height: 6.0,
        child: Container(
          width: constraints.maxWidth * 310.000,
          height: constraints.maxHeight * 6.000,
          decoration: BoxDecoration(
            color: Color(0xff0068ef),
            borderRadius: BorderRadius.all(Radius.circular(154.0)),
          ),
        ),
      ),
      Positioned(
        left: 0,
        right: 171.0,
        top: 44.0,
        height: 6.0,
        child: Container(
          width: constraints.maxWidth * 139.000,
          height: constraints.maxHeight * 6.000,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(154.0)),
          ),
        ),
      ),
      Positioned(
        right: 167.0,
        width: 12.0,
        top: 41.0,
        height: 12.0,
        child: Image.asset(
          ovrEllipse ?? 'assets/images/0_12538.png',
          width: constraints.maxWidth * 12.000,
          height: constraints.maxHeight * 12.000,
        ),
      ),
      Positioned(
        left: 2.0,
        width: 2.0,
        top: 53.0,
        height: 5.5,
        child: Image.asset(
          ovrLine ?? 'assets/images/0_12539.png',
          width: constraints.maxWidth * 2.000,
          height: constraints.maxHeight * 5.500,
        ),
      ),
      Positioned(
        right: 2.0,
        width: 2.0,
        top: 53.0,
        height: 5.5,
        child: Image.asset(
          ovrLineCopy ?? 'assets/images/0_12540.png',
          width: constraints.maxWidth * 2.000,
          height: constraints.maxHeight * 5.500,
        ),
      ),
    ]);
  }
}
