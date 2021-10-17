import 'package:flutter/material.dart';
import 'package:geniuswallet/widgets/symbols/buy.g.dart';
import 'package:geniuswallet/widgets/symbols/receive.g.dart';
import 'package:geniuswallet/widgets/symbols/send.g.dart';
import 'package:geniuswallet/egg/menu.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/egg/amount.dart';
import 'package:geniuswallet/egg/subtext.dart';
import 'package:geniuswallet/egg/buybuttoncustom.dart';
import 'package:geniuswallet/egg/recievebuttoncustom.dart';
import 'package:geniuswallet/egg/sendbuttoncustom.dart';

class CoverBalance extends StatelessWidget {
  final constraints;
  final ovrCollectibles;
  final ovrFinance;
  final ovrLine;
  final ovrTokens;
  final ovrAmount;
  final ovrText;
  CoverBalance(
    this.constraints, {
    Key key,
    this.ovrCollectibles,
    this.ovrFinance,
    this.ovrLine,
    this.ovrTokens,
    this.ovrAmount,
    this.ovrText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: 0,
        right: 0,
        top: 0,
        height: constraints.maxHeight * 0.818,
        child: Image.asset(
          'assets/images/35_2514.png',
          width: constraints.maxWidth * 376.000,
          height: constraints.maxHeight * 229.000,
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.151,
        width: constraints.maxWidth * 0.701,
        top: 20.45,
        height: 27.0,
        child: Center(
            child: Container(
                width: 263.0,
                child: Menu(
                    child: Stack(children: [
                  Positioned(
                    left: 0,
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
                    left: 0,
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
                    left: 1.0,
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
                    left: 4.0,
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
                    left: 154.5,
                    width: 2.0,
                    top: 4.0,
                    height: 19.0,
                    child: Image.asset(
                      ovrLine ?? 'assets/images/0_12248.png',
                      width: constraints.maxWidth * 2.000,
                      height: constraints.maxHeight * 19.000,
                    ),
                  ),
                  Positioned(
                    left: 80.5,
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
                    left: 164.0,
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
                ])))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.055,
        width: constraints.maxWidth * 0.893,
        top: constraints.maxHeight * 0.287,
        height: constraints.maxHeight * 0.193,
        child: Amount(
            child: Stack(children: [
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.893,
            top: 0,
            height: constraints.maxHeight * 0.193,
            child: Container(
              width: constraints.maxWidth * 335.000,
              height: constraints.maxHeight * 54.000,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.893,
            top: 0,
            height: constraints.maxHeight * 0.193,
            child: Center(
                child: Container(
                    width: 335.0,
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
                        )))),
          ),
        ])),
      ),
      Positioned(
        left: constraints.maxWidth * 0.055,
        width: constraints.maxWidth * 0.893,
        top: constraints.maxHeight * 0.434,
        height: constraints.maxHeight * 0.075,
        child: Subtext(
            child: Stack(children: [
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.893,
            top: 0,
            height: constraints.maxHeight * 0.075,
            child: Container(
              width: constraints.maxWidth * 335.000,
              height: constraints.maxHeight * 21.000,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.893,
            top: 0,
            height: constraints.maxHeight * 0.075,
            child: Center(
                child: Container(
                    width: 335.0,
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
                        )))),
          ),
        ])),
      ),
      Positioned(
        left: constraints.maxWidth * 0.676,
        width: constraints.maxWidth * 0.149,
        top: constraints.maxHeight * 0.72,
        height: constraints.maxHeight * 0.303,
        child: Center(
            child: Container(
                height: 84.79998779296875,
                width: 56.0,
                child: BuyButtonCustom(
                    child: LayoutBuilder(builder: (context, constraints) {
                  return Buy(
                    constraints,
                    ovrBuy: 'Buy',
                  );
                })))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.426,
        width: constraints.maxWidth * 0.149,
        top: constraints.maxHeight * 0.717,
        height: constraints.maxHeight * 0.303,
        child: Center(
            child: Container(
                height: 84.79998779296875,
                width: 56.0,
                child: RecieveButtonCustom(
                    child: LayoutBuilder(builder: (context, constraints) {
                  return Receive(
                    constraints,
                    ovrReceive: 'Receive',
                    ovrVector: 'assets/images/I0_12256;110_3428.png',
                  );
                })))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.175,
        width: constraints.maxWidth * 0.149,
        top: constraints.maxHeight * 0.716,
        height: constraints.maxHeight * 0.303,
        child: Center(
            child: Container(
                height: 84.79998779296875,
                width: 56.0,
                child: SendButtonCustom(
                    child: LayoutBuilder(builder: (context, constraints) {
                  return Send(
                    constraints,
                    ovrSend: 'Send',
                  );
                })))),
      ),
    ]);
  }
}
