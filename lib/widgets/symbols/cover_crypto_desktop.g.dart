import 'package:flutter/material.dart';
import 'package:geniuswallet/widgets/symbols/send.g.dart';
import 'package:geniuswallet/widgets/symbols/receive.g.dart';
import 'package:geniuswallet/widgets/symbols/copy.g.dart';
import 'package:geniuswallet/widgets/symbols/more.g.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CoverCryptoDesktop extends StatelessWidget {
  final constraints;
  final ovrEllipse;
  final ovrTitle;
  final ovrText;
  final ovrAmount;
  final ovrMoreCopy3;
  final ovrMoreCopy2;
  final ovrMoreCopy;
  final ovrMore;
  final ovr418;
  final ovr4630950;
  CoverCryptoDesktop(
    this.constraints, {
    Key key,
    this.ovrEllipse,
    this.ovrTitle,
    this.ovrText,
    this.ovrAmount,
    this.ovrMoreCopy3,
    this.ovrMoreCopy2,
    this.ovrMoreCopy,
    this.ovrMore,
    this.ovr418,
    this.ovr4630950,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: constraints.maxWidth * 0.404,
        width: constraints.maxWidth * 0.17,
        top: constraints.maxHeight * 0.204,
        height: constraints.maxHeight * 0.193,
        child: Image.asset(
          ovrEllipse ?? 'assets/images/0_12664.png',
          width: constraints.maxWidth * 68.000,
          height: constraints.maxHeight * 68.000,
        ),
      ),
      Positioned(
        left: 20.0,
        right: 20.0,
        top: constraints.maxHeight * 0.405,
        height: constraints.maxHeight * 0.181,
        child: Center(
            child: Container(
                height: 64.0,
                child: Stack(children: [
                  Positioned(
                    left: 0,
                    width: constraints.maxWidth * 0.9,
                    top: 0,
                    height: 64.0,
                    child: Container(
                      width: constraints.maxWidth * 359.000,
                      height: constraints.maxHeight * 64.000,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(0)),
                      ),
                    ),
                  ),
                  Positioned(
                    left: constraints.maxWidth * 0.19,
                    width: constraints.maxWidth * 0.521,
                    top: 0,
                    height: 43.0,
                    child: Container(
                        width: constraints.maxWidth * 208.000,
                        height: constraints.maxHeight * 43.000,
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
                    width: constraints.maxWidth * 0.9,
                    top: 43.0,
                    height: 21.0,
                    child: Container(
                        width: constraints.maxWidth * 359.000,
                        height: constraints.maxHeight * 21.000,
                        child: AutoSizeText(
                          ovrText ?? 'Text',
                          style: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 18.0,
                            fontWeight: FontWeight.w100,
                            fontStyle: FontStyle.normal,
                            letterSpacing: 0.0,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        )),
                  ),
                ]))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.326,
        width: constraints.maxWidth * 0.351,
        top: constraints.maxHeight * 0.612,
        height: constraints.maxHeight * 0.034,
        child: Center(
            child: Container(
                height: 12.0,
                width: 140.0,
                child: Stack(children: [
                  Positioned(
                    left: 0,
                    width: 81.0,
                    top: 0,
                    height: 12.0,
                    child: Container(
                        width: constraints.maxWidth * 81.000,
                        height: constraints.maxHeight * 12.000,
                        child: AutoSizeText(
                          ovr4630950 ?? '\$46,309.50',
                          style: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 13.0,
                            fontWeight: FontWeight.w300,
                            fontStyle: FontStyle.normal,
                            letterSpacing: 0.0,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.left,
                        )),
                  ),
                  Positioned(
                    left: 21.0,
                    width: 99.236,
                    top: 0,
                    height: 12.0,
                    child: Container(
                      width: constraints.maxWidth * 99.236,
                      height: constraints.maxHeight * 12.000,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(0)),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 85.0,
                    width: 55.0,
                    top: 0,
                    height: 12.0,
                    child: Container(
                        width: constraints.maxWidth * 55.000,
                        height: constraints.maxHeight * 12.000,
                        child: AutoSizeText(
                          ovr418 ?? '+4.18%',
                          style: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 13.0,
                            fontWeight: FontWeight.w300,
                            fontStyle: FontStyle.normal,
                            letterSpacing: 0.0,
                            color: Color(0xff00f1ac),
                          ),
                          textAlign: TextAlign.left,
                        )),
                  ),
                ]))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.158,
        width: constraints.maxWidth * 0.682,
        top: 18.0,
        height: 48.0,
        child: Center(
            child: Container(
                width: 272.0,
                child: Container(
                    width: constraints.maxWidth * 272.000,
                    height: constraints.maxHeight * 48.000,
                    child: AutoSizeText(
                      ovrTitle ?? 'Title',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 36.0,
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
        width: constraints.maxWidth * 1.0,
        bottom: 0,
        height: 112.0,
        child: Center(
            child: Container(
                width: 399.0,
                child: Stack(children: [
                  Positioned(
                    left: 0,
                    width: 399.0,
                    top: 0,
                    height: 112.0,
                    child: Container(
                      width: constraints.maxWidth * 399.000,
                      height: constraints.maxHeight * 112.000,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(0)),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 322.741,
                    width: 76.259,
                    top: 0,
                    height: 111.736,
                    child: LayoutBuilder(builder: (context, constraints) {
                      return More(
                        constraints,
                        ovrVector: 'assets/images/I0_12670;176_1968.png',
                        ovrMore: 'More',
                      );
                    }),
                  ),
                  Positioned(
                    left: 215.16,
                    width: 76.259,
                    top: 0,
                    height: 111.736,
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Copy(
                        constraints,
                        ovrCopy: 'Copy',
                        ovrRectangle2Difference:
                            'assets/images/I0_12671;0_12458.png',
                      );
                    }),
                  ),
                  Positioned(
                    left: 107.58,
                    width: 76.259,
                    top: 0,
                    height: 111.736,
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Receive(
                        constraints,
                        ovrReceive: 'Receive',
                        ovrVector: 'assets/images/I0_12672;110_3428.png',
                      );
                    }),
                  ),
                  Positioned(
                    left: 0,
                    width: 76.259,
                    top: 0,
                    height: 111.736,
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Send(
                        constraints,
                        ovrSend: 'Send',
                      );
                    }),
                  ),
                ]))),
      ),
    ]);
  }
}
