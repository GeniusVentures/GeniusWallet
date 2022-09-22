// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/total_balance_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/send_custom.dart';
import 'package:genius_wallet/widgets/components/custom/receive_custom.dart';
import 'package:genius_wallet/widgets/components/custom/wallet_address_custom.dart';

class WalletInformation extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrMask;
  final String? ovrTotalbalance;
  final String? ovrCurrency;
  final String? ovrQuantity;
  final String? ovrRecive;
  final String? ovrSend;
  final String? ovr1Cs4wu6pu5qCZ35bSLNV;
  final String? ovrQRcode;
  final String? ovrYourbitcoinaddress;
  const WalletInformation(
    this.constraints, {
    Key? key,
    this.ovrMask,
    this.ovrTotalbalance,
    this.ovrCurrency,
    this.ovrQuantity,
    this.ovrRecive,
    this.ovrSend,
    this.ovr1Cs4wu6pu5qCZ35bSLNV,
    this.ovrQRcode,
    this.ovrYourbitcoinaddress,
  }) : super(key: key);
  @override
  _WalletInformation createState() => _WalletInformation();
}

class _WalletInformation extends State<WalletInformation> {
  _WalletInformation();

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
                height: 91.0,
                child: Center(
                    child: Container(
                        height: 91.0,
                        width: 312.0,
                        child: TotalBalanceCustom(
                            child: Container(
                                decoration: BoxDecoration(),
                                child: Stack(children: [
                                  Positioned(
                                    left: 19.0,
                                    width: 205.0,
                                    top: 35.0,
                                    height: 56.0,
                                    child: Container(
                                        height: 56.0,
                                        width: 205.0,
                                        child: AutoSizeText(
                                          widget.ovrQuantity ?? '0.221746',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 48.0,
                                            fontWeight: FontWeight.w300,
                                            letterSpacing: 1.0,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.left,
                                        )),
                                  ),
                                  Positioned(
                                    right: 39.0,
                                    width: 24.0,
                                    top: 39.0,
                                    height: 14.0,
                                    child: Container(
                                        height: 14.0,
                                        width: 24.0,
                                        child: AutoSizeText(
                                          widget.ovrCurrency ?? 'BTC ',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.25714290142059326,
                                            color: Color(0xff3a3c43),
                                          ),
                                          textAlign: TextAlign.center,
                                        )),
                                  ),
                                  Positioned(
                                    left: 19.0,
                                    width: 80.0,
                                    top: 2.0,
                                    height: 14.0,
                                    child: Container(
                                        height: 14.0,
                                        width: 80.0,
                                        child: AutoSizeText(
                                          widget.ovrTotalbalance ??
                                              'Total balance:',
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
                                    left: 288.0,
                                    width: 4.0,
                                    top: 0,
                                    height: 16.0,
                                    child: widget.ovrMask ??
                                        Image.asset(
                                          'assets/images/mask.png',
                                          package: 'genius_wallet',
                                          height: 16.0,
                                          width: 4.0,
                                          fit: BoxFit.none,
                                        ),
                                  ),
                                ]))))),
              ),
              Positioned(
                left: 0,
                width: widget.constraints.maxWidth * 1.0,
                top: widget.constraints.maxHeight * 0.512,
                height: widget.constraints.maxHeight * 0.108,
                child: Center(
                    child: Container(
                        padding: EdgeInsets.only(
                          left: 20.0,
                          right: 0,
                          top: 0,
                          bottom: 0,
                        ),
                        width: 312.0,
                        decoration: BoxDecoration(),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  height: 23.0,
                                  width: 90.0,
                                  child: SendCustom(
                                      child: Container(
                                          height: 23.0,
                                          width: 90.0,
                                          decoration: BoxDecoration(),
                                          child: Stack(children: [
                                            Positioned(
                                              left: 0,
                                              width: 90.0,
                                              top: 0,
                                              height: 23.0,
                                              child: Container(
                                                height: 23.0,
                                                width: 90.0,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              14.0)),
                                                  border: Border.all(
                                                    color: Color(0xff3f4048),
                                                    width: 2.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: 31.0,
                                              width: 29.0,
                                              top: 4.0,
                                              height: 14.0,
                                              child: Container(
                                                  height: 14.0,
                                                  width: 29.0,
                                                  child: AutoSizeText(
                                                    widget.ovrSend ?? 'Send ',
                                                    style: TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      letterSpacing:
                                                          0.30000001192092896,
                                                      color: Colors.white,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  )),
                                            ),
                                          ])))),
                              SizedBox(
                                width: 18.0,
                              ),
                              Container(
                                  height: 23.0,
                                  width: 164.0,
                                  child: ReceiveCustom(
                                      child: Container(
                                          height: 23.0,
                                          width: 164.0,
                                          decoration: BoxDecoration(),
                                          child: Stack(children: [
                                            Positioned(
                                              left: 0,
                                              width: 164.0,
                                              top: 0,
                                              height: 23.0,
                                              child: Container(
                                                height: 23.0,
                                                width: 164.0,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              14.0)),
                                                  border: Border.all(
                                                    color: Color(0xff7ac231),
                                                    width: 2.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: 48.0,
                                              width: 67.0,
                                              top: 5.0,
                                              height: 14.0,
                                              child: Container(
                                                  height: 14.0,
                                                  width: 67.0,
                                                  child: AutoSizeText(
                                                    widget.ovrRecive ??
                                                        'Receive ',
                                                    style: TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      letterSpacing:
                                                          0.30000001192092896,
                                                      color: Colors.white,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  )),
                                            ),
                                          ])))),
                            ]))),
              ),
              Positioned(
                left: 0,
                width: widget.constraints.maxWidth * 1.0,
                bottom: 0,
                height: 63.0,
                child: Center(
                    child: Container(
                        height: 63.0,
                        width: 312.0,
                        child: WalletAddressCustom(
                            child: Container(
                                decoration: BoxDecoration(),
                                child: Stack(children: [
                                  Positioned(
                                    left: 26.0,
                                    width: 113.0,
                                    top: 0,
                                    height: 14.0,
                                    child: Container(
                                        height: 14.0,
                                        width: 113.0,
                                        child: AutoSizeText(
                                          widget.ovrYourbitcoinaddress ??
                                              'Your bitcoin adress:',
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
                                  Positioned(
                                    left: 228.0,
                                    width: 48.0,
                                    top: 3.0,
                                    height: 14.0,
                                    child: Container(
                                        height: 14.0,
                                        width: 48.0,
                                        child: AutoSizeText(
                                          widget.ovrQRcode ?? 'QR-code',
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
                                    left: 20.0,
                                    width: 271.0,
                                    top: 31.0,
                                    height: 35.0,
                                    child: Container(
                                      height: 35.0,
                                      width: 271.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff2a2b31),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(2.0)),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 28.0,
                                    width: 263.0,
                                    top: 42.0,
                                    height: 14.0,
                                    child: Container(
                                        height: 14.0,
                                        width: 263.0,
                                        child: AutoSizeText(
                                          widget.ovr1Cs4wu6pu5qCZ35bSLNV ??
                                              '1Cs4wu6pu5qCZ35bSLNVzGyEx5N6uzbg9t',
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
                                ]))))),
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
