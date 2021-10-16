import 'package:flutter/material.dart';
import 'package:geniuswallet/widgets/symbols/send.g.dart';
import 'package:geniuswallet/widgets/symbols/receive.g.dart';
import 'package:geniuswallet/widgets/symbols/buy.g.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CoverBalanceDesktop extends StatelessWidget {
  final constraints;
  final ovrCollectibles;
  final ovrFinance;
  final ovrLine;
  final ovrTokens;
  final ovrText;
  final ovrAmount;
  final ovrBuyCopy2;
  final ovrBuyCopy;
  final ovrBuy;
  CoverBalanceDesktop(
    this.constraints, {
    Key key,
    this.ovrCollectibles,
    this.ovrFinance,
    this.ovrLine,
    this.ovrTokens,
    this.ovrText,
    this.ovrAmount,
    this.ovrBuyCopy2,
    this.ovrBuyCopy,
    this.ovrBuy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: 36.0,
        width: 263.0,
        top: 0,
        height: 27.0,
        child: Container(
          width: constraints.maxWidth * 263.000,
          height: constraints.maxHeight * 27.000,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: 36.0,
        width: 263.0,
        top: 0,
        height: 27.0,
        child: Container(
          width: constraints.maxWidth * 263.000,
          height: constraints.maxHeight * 27.000,
          decoration: BoxDecoration(
            color: Color(0xff4f93ec),
            borderRadius: BorderRadius.all(Radius.circular(6.0)),
          ),
        ),
      ),
      Positioned(
        left: 37.0,
        width: 72.0,
        top: 1.0,
        height: 25.0,
        child: Container(
          width: constraints.maxWidth * 72.000,
          height: constraints.maxHeight * 25.000,
          decoration: BoxDecoration(
            color: Color(0xff0050c4),
            borderRadius: BorderRadius.all(Radius.circular(6.0)),
          ),
        ),
      ),
      Positioned(
        left: 0,
        width: 335.0,
        top: 60.0,
        height: 62.0,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: 335.0,
            top: 0,
            height: 62.0,
            child: Container(
              width: constraints.maxWidth * 335.000,
              height: constraints.maxHeight * 62.000,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            width: 335.0,
            top: 0,
            height: 54.0,
            child: Container(
                width: constraints.maxWidth * 335.000,
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
            width: 335.0,
            top: 41.0,
            height: 21.0,
            child: Container(
                width: constraints.maxWidth * 335.000,
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
        left: 40.0,
        width: 66.0,
        top: 4.0,
        height: 19.0,
        child: Container(
            width: constraints.maxWidth * 66.000,
            height: constraints.maxHeight * 19.000,
            child: AutoSizeText(
              ovrTokens ?? 'Tokens',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 14.0,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
      Positioned(
        left: 45.0,
        width: 243.979,
        top: 180.2,
        height: 85.885,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: 243.979,
            top: 0,
            height: 85.885,
            child: Container(
              width: constraints.maxWidth * 243.979,
              height: constraints.maxHeight * 85.885,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
          Positioned(
            left: 187.979,
            width: 56.0,
            top: 1.085,
            height: 84.8,
            child: LayoutBuilder(builder: (context, constraints) {
              return Buy(
                constraints,
                ovrBuy: 'Buy',
              );
            }),
          ),
          Positioned(
            left: 93.99,
            width: 56.0,
            top: 0,
            height: 84.8,
            child: LayoutBuilder(builder: (context, constraints) {
              return Receive(
                constraints,
                ovrReceive: 'Receive',
                ovrVector: 'assets/images/I0_12749;110_3428.png',
              );
            }),
          ),
          Positioned(
            left: 0,
            width: 56.0,
            top: 0,
            height: 84.8,
            child: LayoutBuilder(builder: (context, constraints) {
              return Send(
                constraints,
                ovrSend: 'Send',
              );
            }),
          ),
        ]),
      ),
      Positioned(
        left: 190.5,
        width: 2.0,
        top: 4.0,
        height: 19.0,
        child: Image.asset(
          ovrLine ?? 'assets/images/0_12741.png',
          width: constraints.maxWidth * 2.000,
          height: constraints.maxHeight * 19.000,
        ),
      ),
      Positioned(
        left: 116.5,
        width: 66.0,
        top: 4.0,
        height: 19.0,
        child: Container(
            width: constraints.maxWidth * 66.000,
            height: constraints.maxHeight * 19.000,
            child: AutoSizeText(
              ovrFinance ?? 'Finance',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 14.0,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
      Positioned(
        left: 200.0,
        width: 92.0,
        top: 4.0,
        height: 19.0,
        child: Container(
            width: constraints.maxWidth * 92.000,
            height: constraints.maxHeight * 19.000,
            child: AutoSizeText(
              ovrCollectibles ?? 'Collectibles',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 14.0,
                fontWeight: FontWeight.w300,
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
