// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WalletModule extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrCoinImage;
  final String? ovrWalletBalance;
  final String? ovrCoinName;
  final String? ovrLastTransactionID;
  final String? ovrLastTransactionValue;
  final String? ovrTimestamp;
  final Widget? ovrTrendLine;
  final String? ovrCoinSymbol;
  const WalletModule(
    this.constraints, {
    Key? key,
    this.ovrCoinImage,
    this.ovrWalletBalance,
    this.ovrCoinName,
    this.ovrLastTransactionID,
    this.ovrLastTransactionValue,
    this.ovrTimestamp,
    this.ovrTrendLine,
    this.ovrCoinSymbol,
  }) : super(key: key);
  @override
  _WalletModule createState() => _WalletModule();
}

class _WalletModule extends State<WalletModule> {
  _WalletModule();

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
                width: widget.constraints.maxWidth * 1.0,
                top: 0,
                height: widget.constraints.maxHeight * 1.0,
                child: Container(
                  height: widget.constraints.maxHeight * 1.0,
                  width: widget.constraints.maxWidth * 1.0,
                  decoration: BoxDecoration(
                    color: Color(0xff1d2024),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.064,
                width: widget.constraints.maxWidth * 0.113,
                top: widget.constraints.maxHeight * 0.094,
                height: widget.constraints.maxHeight * 0.118,
                child: widget.ovrCoinImage ??
                    Image.asset(
                      'assets/images/coinimage.png',
                      package: 'genius_wallet',
                      height:
                          widget.constraints.maxHeight * 0.11784511784511785,
                      width: widget.constraints.maxWidth * 0.11254019292604502,
                      fit: BoxFit.fill,
                    ),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.514,
                width: widget.constraints.maxWidth * 0.421,
                top: widget.constraints.maxHeight * 0.155,
                height: widget.constraints.maxHeight * 0.111,
                child: Container(
                    height: widget.constraints.maxHeight * 0.1111111111111111,
                    width: widget.constraints.maxWidth * 0.4212218649517685,
                    child: AutoSizeText(
                      widget.ovrWalletBalance ?? '0.221746',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 28.0,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.28000009059906006,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.right,
                    )),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.219,
                width: widget.constraints.maxWidth * 0.283,
                top: widget.constraints.maxHeight * 0.114,
                height: widget.constraints.maxHeight * 0.077,
                child: Container(
                    height: widget.constraints.maxHeight * 0.07744107744107744,
                    width: widget.constraints.maxWidth * 0.2829581993569132,
                    child: AutoSizeText(
                      widget.ovrCoinName ?? 'Bitcoin',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 20.0,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.25,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 20.0,
                right: 20.0,
                bottom: 22.0,
                height: 72.0,
                child: Container(
                    decoration: BoxDecoration(),
                    child: Stack(children: [
                      Positioned(
                        left: 0,
                        width: widget.constraints.maxWidth * 0.871,
                        top: 0,
                        height: 72.0,
                        child: Container(
                          height: 72.0,
                          width:
                              widget.constraints.maxWidth * 0.8713826366559485,
                          decoration: BoxDecoration(
                            color: Color(0xff2a2b31),
                            borderRadius:
                                BorderRadius.all(Radius.circular(2.0)),
                          ),
                        ),
                      ),
                      Positioned(
                        left: widget.constraints.maxWidth * 0.061,
                        width: widget.constraints.maxWidth * 0.338,
                        top: 13.0,
                        height: 12.0,
                        child: Container(
                            height: 12.0,
                            width: widget.constraints.maxWidth *
                                0.33762057877813506,
                            child: AutoSizeText(
                              widget.ovrTimestamp ?? '16:01, 12 dec 2018',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 10.0,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.25,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.left,
                            )),
                      ),
                      Positioned(
                        left: widget.constraints.maxWidth * 0.582,
                        width: widget.constraints.maxWidth * 0.244,
                        top: 13.0,
                        height: 14.0,
                        child: Container(
                            height: 14.0,
                            width: widget.constraints.maxWidth *
                                0.24437299035369775,
                            child: AutoSizeText(
                              widget.ovrLastTransactionValue ?? '+1.045 BTC',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.0,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.left,
                            )),
                      ),
                      Positioned(
                        left: widget.constraints.maxWidth * 0.039,
                        width: widget.constraints.maxWidth * 0.788,
                        top: 45.0,
                        height: 14.0,
                        child: Container(
                            height: 14.0,
                            width: widget.constraints.maxWidth *
                                0.7877813504823151,
                            child: AutoSizeText(
                              widget.ovrLastTransactionID ??
                                  '1PRj85hu9RXPZTzxtko9stfs6nRo1vyrQB',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.30000001192092896,
                                color: Color(0xff42434b),
                              ),
                              textAlign: TextAlign.center,
                            )),
                      ),
                    ])),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.064,
                width: widget.constraints.maxWidth * 0.871,
                top: widget.constraints.maxHeight * 0.293,
                height: widget.constraints.maxHeight * 0.296,
                child: widget.ovrTrendLine ??
                    SvgPicture.asset(
                      'assets/images/trendline.svg',
                      package: 'genius_wallet',
                      height: widget.constraints.maxHeight * 0.2962962962962963,
                      width: widget.constraints.maxWidth * 0.8713826366559485,
                      fit: BoxFit.fill,
                    ),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.727,
                width: widget.constraints.maxWidth * 0.209,
                top: widget.constraints.maxHeight * 0.094,
                height: widget.constraints.maxHeight * 0.047,
                child: Container(
                    height: widget.constraints.maxHeight * 0.04713804713804714,
                    width: widget.constraints.maxWidth * 0.2090032154340836,
                    child: AutoSizeText(
                      widget.ovrCoinSymbol ?? 'Btc',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2571428716182709,
                        color: Color(0xff3a3c43),
                      ),
                      textAlign: TextAlign.right,
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
