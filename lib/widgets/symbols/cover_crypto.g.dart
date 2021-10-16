import 'package:flutter/material.dart';
import 'package:geniuswallet/widgets/symbols/send.g.dart';
import 'package:geniuswallet/widgets/symbols/receive.g.dart';
import 'package:geniuswallet/widgets/symbols/copy.g.dart';
import 'package:geniuswallet/widgets/symbols/more.g.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CoverCrypto extends StatelessWidget {
  final constraints;
  final ovrEllipse;
  final ovrTitle;
  final ovrText;
  final ovrAmount;
  final ovrMoreCopy3;
  final ovrMoreCopy2;
  final ovrMoreCopy;
  final ovrMore;
  final ovr4630950;
  final ovr418;
  CoverCrypto(
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
    this.ovr4630950,
    this.ovr418,
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
          'assets/images/0_12176.png',
          width: constraints.maxWidth * 386.027,
          height: constraints.maxHeight * 229.000,
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.43,
        width: constraints.maxWidth * 0.14,
        top: 52.45,
        height: 54.0,
        child: Image.asset(
          ovrEllipse ?? 'assets/images/0_12183.png',
          width: constraints.maxWidth * 54.000,
          height: constraints.maxHeight * 54.000,
        ),
      ),
      Positioned(
        left: 20.616,
        right: 20.411,
        top: 106.45,
        height: 64.0,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.896,
            top: 0,
            height: 64.0,
            child: Container(
              width: constraints.maxWidth * 345.000,
              height: constraints.maxHeight * 64.000,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.896,
            top: 0,
            height: 54.0,
            child: Container(
                width: constraints.maxWidth * 345.000,
                height: constraints.maxHeight * 54.000,
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
                )),
          ),
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.896,
            top: 43.0,
            height: 21.0,
            child: Container(
                width: constraints.maxWidth * 345.000,
                height: constraints.maxHeight * 21.000,
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
                )),
          ),
        ]),
      ),
      Positioned(
        left: 63.816,
        right: 64.211,
        top: 18.45,
        height: 27.0,
        child: Container(
            width: constraints.maxWidth * 258.000,
            height: constraints.maxHeight * 27.000,
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
        left: constraints.maxWidth * 0.121,
        width: constraints.maxWidth * 0.761,
        top: 200.65,
        height: 84.8,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.761,
            top: 0,
            height: 84.8,
            child: Container(
              width: constraints.maxWidth * 293.000,
              height: constraints.maxHeight * 84.800,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
          Positioned(
            left: constraints.maxWidth * 0.616,
            width: constraints.maxWidth * 0.145,
            top: 0,
            height: 84.8,
            child: Center(
                child: Container(
                    width: 56.0,
                    child: LayoutBuilder(builder: (context, constraints) {
                      return More(
                        constraints,
                        ovrVector: 'assets/images/I0_12189;176_1968.png',
                        ovrMore: 'More',
                      );
                    }))),
          ),
          Positioned(
            left: constraints.maxWidth * 0.41,
            width: constraints.maxWidth * 0.145,
            top: 0,
            height: 84.8,
            child: Center(
                child: Container(
                    width: 56.0,
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Copy(
                        constraints,
                        ovrCopy: 'Copy',
                        ovrRectangle2Difference:
                            'assets/images/I0_12190;0_12458.png',
                      );
                    }))),
          ),
          Positioned(
            left: constraints.maxWidth * 0.205,
            width: constraints.maxWidth * 0.145,
            top: 0,
            height: 84.8,
            child: Center(
                child: Container(
                    width: 56.0,
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Receive(
                        constraints,
                        ovrReceive: 'Receive',
                        ovrVector: 'assets/images/I0_12191;110_3428.png',
                      );
                    }))),
          ),
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.145,
            top: 0,
            height: 84.8,
            child: Center(
                child: Container(
                    width: 56.0,
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Send(
                        constraints,
                        ovrSend: 'Send',
                      );
                    }))),
          ),
        ]),
      ),
      Positioned(
        left: constraints.maxWidth * 0.376,
        width: constraints.maxWidth * 0.151,
        top: 173.45,
        height: 12.0,
        child: Container(
            width: constraints.maxWidth * 58.000,
            height: constraints.maxHeight * 12.000,
            child: AutoSizeText(
              ovr4630950 ?? '\$46,309.50',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 11.0,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.left,
            )),
      ),
      Positioned(
        left: constraints.maxWidth * 0.542,
        width: constraints.maxWidth * 0.088,
        top: 173.45,
        height: 12.0,
        child: Container(
            width: constraints.maxWidth * 34.000,
            height: constraints.maxHeight * 12.000,
            child: AutoSizeText(
              ovr418 ?? '+4.18%',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 11.0,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Color(0xff00f1ac),
              ),
              textAlign: TextAlign.left,
            )),
      ),
    ]);
  }
}
