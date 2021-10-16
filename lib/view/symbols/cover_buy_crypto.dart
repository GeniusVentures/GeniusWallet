import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CoverBuyCrypto extends StatelessWidget {
  final constraints;

  CoverBuyCrypto(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: constraints.maxWidth * 1.003,
        height: constraints.maxHeight * 0.983,
        child: Align(
          alignment: Alignment(0.00, 0.00),
          child: Stack(children: [
            Image.asset(
              'assets/images/0_12198.png',
              width: constraints.maxWidth * 1.003,
              height: constraints.maxHeight * 0.983,
            ),
            Positioned(
              left: constraints.maxWidth * 0.003,
              right: constraints.maxWidth * 0.000,
              top: constraints.maxHeight * 0.000,
              bottom: constraints.maxHeight * 0.000,
              child: Container(
                width: constraints.maxWidth * 1.000,
                height: constraints.maxHeight * 0.983,
                decoration: BoxDecoration(
                  color: Color(0xff0050c4),
                ),
              ),
            ),
            Positioned(
              left: constraints.maxWidth * 0.165,
              right: constraints.maxWidth * 0.167,
              top: constraints.maxHeight * 0.066,
              bottom: constraints.maxHeight * 0.820,
              child: Container(
                  width: constraints.maxWidth * 0.670,
                  height: constraints.maxHeight * 0.096,
                  child: Align(
                    alignment: Alignment(0.00, 0.00),
                    child: AutoSizeText(
                      'Title',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )),
            ),
            Positioned(
              left: constraints.maxWidth * 0.054,
              right: constraints.maxWidth * 0.053,
              top: constraints.maxHeight * 0.315,
              bottom: constraints.maxHeight * 0.298,
              child: Container(
                  width: constraints.maxWidth * 0.896,
                  height: constraints.maxHeight * 0.369,
                  child: Align(
                    alignment: Alignment(0.00, 0.00),
                    child: Stack(children: [
                      Positioned(
                        left: constraints.maxWidth * 0.000,
                        right: constraints.maxWidth * 0.000,
                        top: constraints.maxHeight * 0.000,
                        bottom: constraints.maxHeight * 0.056,
                        child: Container(
                            width: constraints.maxWidth * 0.896,
                            height: constraints.maxHeight * 0.313,
                            child: Align(
                              alignment: Alignment(0.00, 0.00),
                              child: AutoSizeText(
                                'Amount',
                                style: TextStyle(
                                  fontFamily: 'Prompt',
                                  fontSize: 48.0,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,
                                  letterSpacing: 0.0,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )),
                      ),
                      Positioned(
                        left: constraints.maxWidth * 0.000,
                        right: constraints.maxWidth * 0.000,
                        top: constraints.maxHeight * 0.266,
                        bottom: constraints.maxHeight * 0.000,
                        child: Container(
                            width: constraints.maxWidth * 0.896,
                            height: constraints.maxHeight * 0.103,
                            child: Align(
                              alignment: Alignment(0.00, 0.00),
                              child: AutoSizeText(
                                'Text',
                                style: TextStyle(
                                  fontFamily: 'Prompt',
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w100,
                                  fontStyle: FontStyle.normal,
                                  letterSpacing: 0.0,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )),
                      ),
                    ]),
                  )),
            ),
          ]),
        ));
  }
}
