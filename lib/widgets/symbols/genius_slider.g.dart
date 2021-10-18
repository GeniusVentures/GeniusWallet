import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class GeniusSlider extends StatelessWidget {
  final constraints;
  final ovrType;
  final ovrTypeCopy3;
  final ovrTypeCopy;
  final ovrTypeCopy2;
  GeniusSlider(
    this.constraints, {
    Key key,
    this.ovrType,
    this.ovrTypeCopy3,
    this.ovrTypeCopy,
    this.ovrTypeCopy2,
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
        left: constraints.maxWidth * 0.431,
        width: constraints.maxWidth * 0.135,
        top: constraints.maxHeight * 0.695,
        height: constraints.maxHeight * 0.329,
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
        width: constraints.maxWidth * 0.074,
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
        left: constraints.maxWidth * 0.926,
        width: constraints.maxWidth * 0.074,
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
        width: constraints.maxWidth * 1.0,
        top: constraints.maxHeight * 0.5,
        height: constraints.maxHeight * 0.213,
        child: Image.asset(
          'assets/images/218_3916.png',
          width: constraints.maxWidth * 310.000,
          height: constraints.maxHeight * 17.500,
        ),
      ),
    ]);
  }
}
