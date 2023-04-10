// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/desktop/custom/send_button_custom.dart';

class AssetPercentageCard extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrSendto;
  final String? ovrAmount;
  final String? ovrWallet;
  final String? ovrReceiceBitcoin;
  final String? ovrBTC;
  final String? ovr0233455;
  final String? ovr1Cs4wu6pu5qCZ35bSLNV;
  final String? ovrsend;
  final Widget? ovrMask;
  const AssetPercentageCard(
    this.constraints, {
    Key? key,
    this.ovrSendto,
    this.ovrAmount,
    this.ovrWallet,
    this.ovrReceiceBitcoin,
    this.ovrBTC,
    this.ovr0233455,
    this.ovr1Cs4wu6pu5qCZ35bSLNV,
    this.ovrsend,
    this.ovrMask,
  }) : super(key: key);
  @override
  _AssetPercentageCard createState() => _AssetPercentageCard();
}

class _AssetPercentageCard extends State<AssetPercentageCard> {
  _AssetPercentageCard();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.025,
            child: Stack(children: [
              Positioned(
                left: 0,
                width: 402.0,
                top: 0,
                height: 164.0,
                child: Container(
                  height: 164.0,
                  width: 402.0,
                  decoration: BoxDecoration(
                    color: Color(0xff1e2025),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
              Positioned(
                left: 23.0,
                width: 48.0,
                top: 75.0,
                height: 13.0,
                child: Container(
                    height: 13.0,
                    width: 48.0,
                    child: AutoSizeText(
                      widget.ovrSendto ?? 'Send to',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4124999940395355,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.right,
                    )),
              ),
              Positioned(
                left: 230.0,
                width: 49.0,
                top: 30.0,
                height: 13.0,
                child: Container(
                    height: 13.0,
                    width: 49.0,
                    child: AutoSizeText(
                      widget.ovrAmount ?? 'Amount',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4124999940395355,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
              Positioned(
                left: 79.0,
                width: 293.0,
                top: 65.0,
                height: 29.0,
                child: Container(
                  height: 29.0,
                  width: 293.0,
                  decoration: BoxDecoration(
                    color: Color(0xff2a2b31),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
              Positioned(
                left: 23.0,
                width: 44.0,
                top: 30.0,
                height: 13.0,
                child: Container(
                    height: 13.0,
                    width: 44.0,
                    child: AutoSizeText(
                      widget.ovrWallet ?? 'Wallet',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4124999940395355,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.right,
                    )),
              ),
              Positioned(
                left: 79.0,
                width: 88.0,
                top: 121.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 88.0,
                    child: AutoSizeText(
                      widget.ovrReceiceBitcoin ?? 'Receice Bitcoin',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.30000001192092896,
                        color: Color(0xff606166),
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
              Positioned(
                left: 79.0,
                width: 65.0,
                top: 22.0,
                height: 29.0,
                child: Container(
                  height: 29.0,
                  width: 65.0,
                  decoration: BoxDecoration(
                    color: Color(0xff2a2b31),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
              Positioned(
                left: 289.0,
                width: 83.0,
                top: 22.0,
                height: 29.0,
                child: Container(
                  height: 29.0,
                  width: 83.0,
                  decoration: BoxDecoration(
                    color: Color(0xff2a2b31),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
              Positioned(
                left: 90.0,
                width: 23.0,
                top: 30.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 23.0,
                    child: AutoSizeText(
                      widget.ovrBTC ?? 'BTC',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 299.0,
                width: 53.0,
                top: 30.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 53.0,
                    child: AutoSizeText(
                      widget.ovr0233455 ?? '0.233455',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 87.0,
                width: 225.0,
                top: 73.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 225.0,
                    child: AutoSizeText(
                      widget.ovr1Cs4wu6pu5qCZ35bSLNV ??
                          '1Cs4wu6pu5qCZ35bSLNVzGyEx5N6uzb',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.30000001192092896,
                        color: Color(0xff42434b),
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 315.0,
                width: 57.0,
                top: 116.0,
                height: 23.0,
                child: SendButtonCustom(
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(14.0)),
                        ),
                        child: Stack(children: [
                          Positioned(
                            left: 0,
                            width: 57.0,
                            top: 0,
                            height: 23.0,
                            child: Container(
                              height: 23.0,
                              width: 57.0,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14.0)),
                                border: Border.all(
                                  color: Color(0xff3f4048),
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 15.0,
                            width: 28.0,
                            top: 4.0,
                            height: 14.0,
                            child: Container(
                                height: 14.0,
                                width: 28.0,
                                child: AutoSizeText(
                                  widget.ovrsend ?? 'send  ',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.30000001192092896,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                )),
                          ),
                        ]))),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.326,
                width: widget.constraints.maxWidth * 0.018,
                top: widget.constraints.maxHeight * 0.188,
                height: widget.constraints.maxHeight * 0.089,
                child: widget.ovrMask ??
                    Image.asset(
                      'assets/images/mask.png',
                      package: 'genius_wallet',
                      height: widget.constraints.maxHeight * 0.0890625,
                      width: widget.constraints.maxWidth * 0.018078552549751242,
                      fit: BoxFit.fill,
                    ),
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
