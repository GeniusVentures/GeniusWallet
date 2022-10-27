// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/send/property1_default.g.dart';
import 'package:genius_wallet/widgets/components/send/property1_buy.g.dart';
import 'package:genius_wallet/widgets/components/send/property1_receive.g.dart';
import 'package:genius_wallet/widgets/components/custom/total_balance_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/send_button_custom.dart';
import 'package:genius_wallet/widgets/components/custom/buy_button_custom.dart';
import 'package:genius_wallet/widgets/components/custom/receive_button_custom.dart';
import 'package:genius_wallet/widgets/components/custom/wallet_address_custom.dart';
import 'package:genius_wallet/widgets/components/custom/q_r_code_button_custom.dart';

class WalletInformation extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrShowMoreIcon;
  final String? ovrTotalbalance;
  final String? ovrCurrency;
  final String? ovrQuantity;
  final String? ovrAddressField;
  final String? ovrYourbitcoinaddress;
  const WalletInformation(
    this.constraints, {
    Key? key,
    this.ovrShowMoreIcon,
    this.ovrTotalbalance,
    this.ovrCurrency,
    this.ovrQuantity,
    this.ovrAddressField,
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
                                    right: 29.0,
                                    width: 50.0,
                                    top: 39.0,
                                    height: 14.0,
                                    child: Container(
                                        height: 14.0,
                                        width: 50.0,
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
                                    width: 111.0,
                                    top: 2.0,
                                    height: 14.0,
                                    child: Container(
                                        height: 14.0,
                                        width: 111.0,
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
                                          textAlign: TextAlign.left,
                                        )),
                                  ),
                                  Positioned(
                                    left: 288.0,
                                    width: 4.0,
                                    top: 0,
                                    height: 16.0,
                                    child: widget.ovrShowMoreIcon ??
                                        Image.asset(
                                          'assets/images/showmoreicon.png',
                                          package: 'genius_wallet',
                                          height: 16.0,
                                          width: 4.0,
                                          fit: BoxFit.none,
                                        ),
                                  ),
                                ]))))),
              ),
              Positioned(
                left: 4.0,
                right: 5.0,
                top: 107.0,
                height: 23.0,
                child: Container(
                    decoration: BoxDecoration(),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              height: 23.0,
                              width: 90.0,
                              child: SendButtonCustom(child: LayoutBuilder(
                                  builder: (context, constraints) {
                                return Property1Default(
                                  constraints,
                                  ovrSend: 'Send ',
                                );
                              }))),
                          Container(
                              height: 23.0,
                              width: 90.0,
                              child: BuyButtonCustom(child: LayoutBuilder(
                                  builder: (context, constraints) {
                                return Property1Buy(
                                  constraints,
                                  ovrSend: 'Buy',
                                );
                              }))),
                          Container(
                              height: 23.0,
                              width: 90.0,
                              child: ReceiveButtonCustom(child: LayoutBuilder(
                                  builder: (context, constraints) {
                                return Property1Receive(
                                  constraints,
                                  ovrSend: 'Receive',
                                );
                              }))),
                        ])),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.067,
                width: widget.constraints.maxWidth * 0.865,
                bottom: 0,
                height: 35.0,
                child: Center(
                    child: Container(
                        height: 35.0,
                        width: 270.0,
                        child: WalletAddressCustom(
                            child: Container(
                                decoration: BoxDecoration(),
                                child: Stack(children: [
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    top: 0,
                                    bottom: 0,
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
                                    left: 8.0,
                                    right: 0,
                                    top: 11.0,
                                    bottom: 10.0,
                                    child: Container(
                                        height: 14.0,
                                        width: 263.0,
                                        child: AutoSizeText(
                                          widget.ovrAddressField ??
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
              Positioned(
                left: 20.0,
                width: 139.0,
                bottom: 49.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 139.0,
                    child: AutoSizeText(
                      widget.ovrYourbitcoinaddress ?? 'Your bitcoin adress:',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                right: 21.0,
                width: 63.0,
                bottom: 49.0,
                height: 14.0,
                child: QRCodeButtonCustom(
                    child: AutoSizeText(
                  'QR-code',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.30000001192092896,
                    color: Color(0xff606166),
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
