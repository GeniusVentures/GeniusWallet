import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CoverBuyCrypto extends StatelessWidget {
  final constraints;
  final ovrTitle;
  final ovrText;
  final ovrAmount;
  CoverBuyCrypto(
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
        left: 0,
        width: constraints.maxWidth * 1.003,
        top: 0,
        height: 229.0,
        child: Container(
          width: constraints.maxWidth * 386.027,
          height: constraints.maxHeight * 229.000,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.003,
        width: constraints.maxWidth * 1.0,
        top: 0,
        height: 229.0,
        child: Container(
          width: constraints.maxWidth * 385.000,
          height: constraints.maxHeight * 229.000,
          decoration: BoxDecoration(
            color: Color(0xff0050c4),
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: 0,
        width: 386.027,
        top: 0,
        height: 229.0,
        child: Image.asset(
          'assets/images/0_12198.png',
          width: constraints.maxWidth * 386.027,
          height: constraints.maxHeight * 229.000,
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.165,
        width: constraints.maxWidth * 0.67,
        top: 15.429,
        height: 22.468,
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
            )),
      ),
      Positioned(
        left: 20.616,
        right: 20.411,
        top: 73.45,
        height: 86.0,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.896,
            top: 0,
            height: 86.0,
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
            height: 73.0,
            child: Center(
                child: Container(
                    width: 345.0,
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
                        )))),
          ),
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.896,
            top: 62.0,
            height: 24.0,
            child: Center(
                child: Container(
                    width: 345.0,
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
                        )))),
          ),
        ]),
      ),
    ]);
  }
}
