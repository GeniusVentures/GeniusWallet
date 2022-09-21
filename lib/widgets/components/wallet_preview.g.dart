// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class WalletPreview extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrCoinType;
  final String? ovrWalletBalance;
  final Widget? ovrShape;
  final String? ovrCoinSymbol;
  const WalletPreview(
    this.constraints, {
    Key? key,
    this.ovrCoinType,
    this.ovrWalletBalance,
    this.ovrShape,
    this.ovrCoinSymbol,
  }) : super(key: key);
  @override
  _WalletPreview createState() => _WalletPreview();
}

class _WalletPreview extends State<WalletPreview> {
  _WalletPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: Stack(children: [
              Positioned(
                left: 0,
                width: 200.0,
                top: 0,
                height: 100.0,
                child: Container(
                  height: 100.0,
                  width: 200.0,
                  decoration: BoxDecoration(
                    color: Color(0xff0068ef),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
              Positioned(
                left: 12.0,
                width: 51.0,
                top: 68.0,
                height: 19.0,
                child: Container(
                    height: 19.0,
                    width: 51.0,
                    child: AutoSizeText(
                      widget.ovrCoinType ?? 'Bitcoin',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
              Positioned(
                left: 87.0,
                width: 102.0,
                top: 60.0,
                height: 28.0,
                child: Container(
                    height: 28.0,
                    width: 102.0,
                    child: AutoSizeText(
                      widget.ovrWalletBalance ?? '0.221746',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 24.0,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.right,
                    )),
              ),
              Positioned(
                left: 156.0,
                width: 35.0,
                top: 9.0,
                height: 35.0,
                child: Container(
                    decoration: BoxDecoration(),
                    child: Stack(children: [
                      Positioned(
                        left: 0,
                        width: 35.0,
                        top: 0,
                        height: 35.0,
                        child: Container(
                          height: 35.0,
                          width: 35.0,
                          decoration: BoxDecoration(
                            color: Color(0xff0050b7),
                            borderRadius:
                                BorderRadius.all(Radius.circular(2.0)),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x2dffffff),
                                spreadRadius: 0.0,
                                blurRadius: 0.0,
                                offset: Offset(0.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8.922,
                        width: 16.484,
                        top: 7.656,
                        height: 21.82,
                        child: widget.ovrShape ??
                            Image.asset(
                              'assets/images/shape.png',
                              package: 'genius_wallet',
                              height: 21.8203125,
                              width: 16.4844970703125,
                              fit: BoxFit.none,
                            ),
                      ),
                    ])),
              ),
              Positioned(
                left: 12.0,
                width: 49.0,
                top: 21.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 49.0,
                    child: AutoSizeText(
                      widget.ovrCoinSymbol ?? 'BTC',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.25714290142059326,
                        color: Color(0xff0050b7),
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
            ]),
          ),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
