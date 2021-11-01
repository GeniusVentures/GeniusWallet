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
        left: constraints.maxWidth * 0.007,
        width: constraints.maxWidth * 0.916,
        top: constraints.maxHeight * 0.003,
        height: constraints.maxHeight * 0.099,
        child: Container(
          width: constraints.maxWidth * 521.000,
          height: constraints.maxHeight * 37.000,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.074,
        width: constraints.maxWidth * 0.777,
        top: 0,
        height: 37.0,
        child: Center(
            child: Container(
                width: 442.0,
                child: Container(
                  width: constraints.maxWidth * 442.000,
                  height: constraints.maxHeight * 37.000,
                  decoration: BoxDecoration(
                    color: Color(0xff4f93ec),
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                  ),
                ))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.077,
        width: constraints.maxWidth * 0.237,
        top: 1.0,
        height: 35.0,
        child: Center(
            child: Container(
                width: 135.0,
                child: Container(
                  width: constraints.maxWidth * 135.000,
                  height: constraints.maxHeight * 35.000,
                  decoration: BoxDecoration(
                    color: Color(0xff0050c4),
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                  ),
                ))),
      ),
      Positioned(
        left: 0,
        right: 0,
        top: constraints.maxHeight * 0.167,
        height: constraints.maxHeight * 0.263,
        child: Center(
            child: Container(
                height: 98.0,
                child: Stack(children: [
                  Positioned(
                    left: 0,
                    width: constraints.maxWidth * 0.93,
                    top: 0,
                    height: 98.0,
                    child: Container(
                      width: constraints.maxWidth * 529.000,
                      height: constraints.maxHeight * 98.000,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(0)),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    width: constraints.maxWidth * 0.93,
                    top: 0,
                    height: 85.355,
                    child: Container(
                        width: constraints.maxWidth * 529.000,
                        height: constraints.maxHeight * 85.355,
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
                    width: constraints.maxWidth * 0.93,
                    top: 64.806,
                    height: 33.194,
                    child: Container(
                        width: constraints.maxWidth * 529.000,
                        height: constraints.maxHeight * 33.194,
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
        left: constraints.maxWidth * 0.091,
        width: constraints.maxWidth * 0.202,
        top: 9.0,
        height: 19.0,
        child: Center(
            child: Container(
                width: 115.0,
                child: Container(
                    width: constraints.maxWidth * 115.000,
                    height: constraints.maxHeight * 19.000,
                    child: AutoSizeText(
                      ovrTokens ?? 'Tokens',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 18.0,
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.167,
        width: constraints.maxWidth * 0.598,
        bottom: 0,
        height: 123.0,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.598,
            top: 0,
            height: 123.0,
            child: Container(
              width: constraints.maxWidth * 340.000,
              height: constraints.maxHeight * 123.000,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
          Positioned(
            left: constraints.maxWidth * 0.413,
            width: constraints.maxWidth * 0.148,
            top: 1.0,
            height: 122.0,
            child: Center(
                child: Container(
                    width: 84.0,
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Buy(
                        constraints,
                        ovrBuy: 'Buy',
                        ovrVector: Image.asset(
                          'assets/images/I0_12748;222_3028.png',
                          width: constraints.maxWidth * 30.991,
                          height: constraints.maxHeight * 30.991,
                        ),
                      );
                    }))),
          ),
          Positioned(
            left: constraints.maxWidth * 0.214,
            width: constraints.maxWidth * 0.148,
            top: 0,
            height: 122.0,
            child: Center(
                child: Container(
                    width: 84.0,
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Receive(
                        constraints,
                        ovrReceive: 'Receive',
                        ovrVector: Image.asset(
                          'assets/images/I0_12749;110_3428.png',
                          width: constraints.maxWidth * 23.899,
                          height: constraints.maxHeight * 12.071,
                        ),
                      );
                    }))),
          ),
          Positioned(
            left: constraints.maxWidth * 0.016,
            width: constraints.maxWidth * 0.148,
            top: 0,
            height: 122.0,
            child: Center(
                child: Container(
                    width: 84.0,
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
        left: constraints.maxWidth * 0.577,
        width: constraints.maxWidth * 0.004,
        top: 4.0,
        height: 29.0,
        child: Center(
            child: Container(
                width: 2.0,
                child: ovrLine ??
                    Image.asset(
                      'assets/images/0_12741.png',
                      width: constraints.maxWidth * 2.000,
                      height: constraints.maxHeight * 29.000,
                    ))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.332,
        width: constraints.maxWidth * 0.211,
        top: 9.0,
        height: 19.0,
        child: Center(
            child: Container(
                width: 120.0,
                child: Container(
                    width: constraints.maxWidth * 120.000,
                    height: constraints.maxHeight * 19.000,
                    child: AutoSizeText(
                      ovrFinance ?? 'Finance',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 18.0,
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.603,
        width: constraints.maxWidth * 0.22,
        top: 9.0,
        height: 19.0,
        child: Center(
            child: Container(
                width: 125.0,
                child: Container(
                    width: constraints.maxWidth * 125.000,
                    height: constraints.maxHeight * 19.000,
                    child: AutoSizeText(
                      ovrCollectibles ?? 'Collectibles',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 18.0,
                        fontWeight: FontWeight.w300,
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
