import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CoverBuyCryptoDesktop extends StatelessWidget {
  final constraints;
  final ovrTitle;
  final ovrText;
  final ovrAmount;
  CoverBuyCryptoDesktop(
    this.constraints, {
    Key key,
    this.ovrTitle,
    this.ovrText,
    this.ovrAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: constraints.maxWidth * 0.112,
        width: constraints.maxWidth * 0.67,
        top: 0,
        height: constraints.maxHeight * 0.096,
        child: Center(
            child: Container(
                width: 258.0,
                child: Container(
                    width: constraints.maxWidth * 258.000,
                    height: constraints.maxHeight * 22.468,
                    child: AutoSizeText(
                      ovrTitle ?? 'Title',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )))),
      ),
      Positioned(
        left: 0,
        right: 0,
        top: 58.021,
        bottom: 0,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.896,
            top: 0,
            height: constraints.maxHeight * 0.369,
            child: Container(
              width: constraints.maxWidth * 345.000,
              height: constraints.maxHeight * 86.000,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.896,
            top: 0,
            height: constraints.maxHeight * 0.313,
            child: Container(
                width: constraints.maxWidth * 345.000,
                height: constraints.maxHeight * 73.000,
                child: AutoSizeText(
                  ovrAmount ?? 'Amount',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 48.0,
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
            right: 0,
            top: 62.0,
            bottom: 0,
            child: Container(
                width: constraints.maxWidth * 345.000,
                height: constraints.maxHeight * 24.000,
                child: AutoSizeText(
                  ovrText ?? 'Text',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 16.0,
                    fontWeight: FontWeight.w100,
                    fontStyle: FontStyle.normal,
                    letterSpacing: 0.0,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                )),
          ),
        ]),
      ),
    ]);
  }
}
