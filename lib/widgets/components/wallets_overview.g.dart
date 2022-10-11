// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/buy_button_custom.dart';

class WalletsOverview extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrCurrentbalance;
  final String? ovrPercentChange;
  final String? ovrCurrencyChange;
  final String? ovrTotalWalletBalance;
  final String? ovrBalancecurrency;
  final String? ovrWalletCounter;
  final String? ovrWallets;
  final String? ovrTransactions;
  final String? ovrTransactionCounter;
  final String? ovrbuy;
  const WalletsOverview(
    this.constraints, {
    Key? key,
    this.ovrCurrentbalance,
    this.ovrPercentChange,
    this.ovrCurrencyChange,
    this.ovrTotalWalletBalance,
    this.ovrBalancecurrency,
    this.ovrWalletCounter,
    this.ovrWallets,
    this.ovrTransactions,
    this.ovrTransactionCounter,
    this.ovrbuy,
  }) : super(key: key);
  @override
  _WalletsOverview createState() => _WalletsOverview();
}

class _WalletsOverview extends State<WalletsOverview> {
  _WalletsOverview();

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
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  height: widget.constraints.maxHeight * 1.0,
                  width: widget.constraints.maxWidth * 1.0,
                  decoration: BoxDecoration(
                    color: Color(0xff2a2b31),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
              Positioned(
                left: 18.0,
                width: 90.0,
                bottom: 139.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 90.0,
                    child: AutoSizeText(
                      widget.ovrCurrentbalance ?? 'Current balance',
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
                left: 105.0,
                width: 31.0,
                bottom: 31.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 31.0,
                    child: AutoSizeText(
                      widget.ovrPercentChange ?? '+12%',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.30000001192092896,
                        color: Color(0xff0068ef),
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 19.0,
                width: 70.0,
                bottom: 31.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 70.0,
                    child: AutoSizeText(
                      widget.ovrCurrencyChange ?? '2.7995  EUR',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 19.0,
                width: 147.0,
                bottom: 77.0,
                height: 56.0,
                child: Container(
                    height: 56.0,
                    width: 147.0,
                    child: AutoSizeText(
                      widget.ovrTotalWalletBalance ?? '3.4330 ',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 48.0,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.3272727131843567,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 162.0,
                width: 24.0,
                bottom: 121.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 24.0,
                    child: AutoSizeText(
                      widget.ovrBalancecurrency ?? 'USD ',
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
                right: 20.0,
                width: 65.0,
                top: 29.0,
                height: 76.0,
                child: Container(
                    decoration: BoxDecoration(),
                    child: Stack(children: [
                      Positioned(
                        left: 0,
                        width: 65.0,
                        top: 0,
                        height: 76.0,
                        child: Container(
                          height: 76.0,
                          width: 65.0,
                          decoration: BoxDecoration(
                            color: Color(0xff252529),
                            borderRadius:
                                BorderRadius.all(Radius.circular(2.0)),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10.0,
                        width: 45.0,
                        top: 49.0,
                        height: 15.0,
                        child: Container(
                            height: 15.0,
                            width: 45.0,
                            child: AutoSizeText(
                              widget.ovrWallets ?? 'Wallets',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 13.0,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.0,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            )),
                      ),
                      Positioned(
                        left: 22.0,
                        width: 20.0,
                        top: 6.0,
                        height: 40.0,
                        child: Container(
                            height: 40.0,
                            width: 20.0,
                            child: AutoSizeText(
                              widget.ovrWalletCounter ?? '5 ',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 34.0,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 0.0,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            )),
                      ),
                    ])),
              ),
              Positioned(
                left: 17.0,
                width: 73.0,
                top: 79.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 73.0,
                    child: AutoSizeText(
                      widget.ovrTransactions ?? 'Transactions',
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
              Positioned(
                left: 20.0,
                width: 84.0,
                top: 34.0,
                height: 40.0,
                child: Container(
                    height: 40.0,
                    width: 84.0,
                    child: AutoSizeText(
                      widget.ovrTransactionCounter ?? '2,345 ',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 34.0,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                right: 20.0,
                width: 47.0,
                bottom: 27.0,
                height: 23.0,
                child: BuyButtonCustom(
                    child: Container(
                        decoration: BoxDecoration(),
                        child: Stack(children: [
                          Positioned(
                            left: 0,
                            width: 47.0,
                            top: 0,
                            height: 23.0,
                            child: Container(
                              height: 23.0,
                              width: 47.0,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14.0)),
                                border: Border.all(
                                  color: Color(0xff0068ef),
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12.0,
                            width: 22.0,
                            top: 4.0,
                            height: 14.0,
                            child: Container(
                                height: 14.0,
                                width: 22.0,
                                child: AutoSizeText(
                                  widget.ovrbuy ?? 'Buy ',
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
            ]),
          ),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
