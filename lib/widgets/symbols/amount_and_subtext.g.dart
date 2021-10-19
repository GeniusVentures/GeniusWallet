import 'package:flutter/material.dart';
import 'package:geniuswallet/egg/amountandsubtextcustom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class AmountAndSubtext extends StatelessWidget {
  final constraints;
  final ovrAmount;
  final ovrText;
  AmountAndSubtext(
    this.constraints, {
    Key key,
    this.ovrAmount,
    this.ovrText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: 0,
        width: constraints.maxWidth * 1.0,
        top: 0,
        height: constraints.maxHeight * 1.0,
        child: Center(
            child: Container(
                width: 335.0,
                child: Container(
                    width: constraints.maxWidth * 335.000,
                    height: constraints.maxHeight * 75.000,
                    child: AutoSizeText(
                      ovrAmount ?? 'Amount',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 36.0,
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
        width: constraints.maxWidth * 1.0,
        top: constraints.maxHeight * 0.559,
        height: constraints.maxHeight * 0.389,
        child: Center(
            child: Container(
                width: 335.0,
                child: Container(
                    width: constraints.maxWidth * 335.000,
                    height: constraints.maxHeight * 29.167,
                    child: AutoSizeText(
                      ovrText ?? 'Text',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w100,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )))),
      ),
    ]);
  }
}
