// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/nav_wallet_button_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/nav_timer_button_custom.dart';

class TabbaractiveTrade extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrWallets;
  final String? ovrTransactions;
  final String? ovrTrade;
  final String? ovrDashboard;
  const TabbaractiveTrade(
    this.constraints, {
    Key? key,
    this.ovrWallets,
    this.ovrTransactions,
    this.ovrTrade,
    this.ovrDashboard,
  }) : super(key: key);
  @override
  _TabbaractiveTrade createState() => _TabbaractiveTrade();
}

class _TabbaractiveTrade extends State<TabbaractiveTrade> {
  _TabbaractiveTrade();

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
            child: Container(
                decoration: BoxDecoration(),
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
                        color: Color(0xff1e2025),
                        border: Border.all(
                          color: Color(0xff0068ef),
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    width: widget.constraints.maxWidth * 1.0,
                    top: widget.constraints.maxHeight * 0.016,
                    height: widget.constraints.maxHeight * 0.984,
                    child: Container(
                      height: widget.constraints.maxHeight * 0.9841269841269841,
                      width: widget.constraints.maxWidth * 1.0,
                      decoration: BoxDecoration(
                        color: Color(0xff1e2025),
                      ),
                    ),
                  ),
                  Positioned(
                    left: widget.constraints.maxWidth * 0.315,
                    width: widget.constraints.maxWidth * 0.112,
                    top: widget.constraints.maxHeight * 0.175,
                    height: widget.constraints.maxHeight * 0.603,
                    child: Container(
                        decoration: BoxDecoration(),
                        child: Stack(children: [
                          Positioned(
                            left: widget.constraints.maxWidth * 0.029,
                            width: widget.constraints.maxWidth * 0.047,
                            top: 0,
                            height: widget.constraints.maxHeight * 0.286,
                            child: NavWalletButtonCustom(
                                child: SvgPicture.asset(
                              'assets/images/navwalletbuttoncustom.svg',
                              package: 'genius_wallet',
                              height: widget.constraints.maxHeight *
                                  0.2857142857142857,
                              width: widget.constraints.maxWidth *
                                  0.04676822916666667,
                              fit: BoxFit.fill,
                            )),
                          ),
                          Positioned(
                            left: 0,
                            width: widget.constraints.maxWidth * 0.112,
                            top: widget.constraints.maxHeight * 0.381,
                            height: widget.constraints.maxHeight * 0.222,
                            child: Container(
                                height: widget.constraints.maxHeight *
                                    0.2222222222222222,
                                width: widget.constraints.maxWidth * 0.112,
                                child: AutoSizeText(
                                  widget.ovrWallets ?? 'Wallets',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.30000001192092896,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                )),
                          ),
                        ])),
                  ),
                  Positioned(
                    left: widget.constraints.maxWidth * 0.531,
                    width: widget.constraints.maxWidth * 0.195,
                    top: widget.constraints.maxHeight * 0.127,
                    height: widget.constraints.maxHeight * 0.651,
                    child: Container(
                        decoration: BoxDecoration(),
                        child: Stack(children: [
                          Positioned(
                            left: 0,
                            width: widget.constraints.maxWidth * 0.195,
                            top: widget.constraints.maxHeight * 0.429,
                            height: widget.constraints.maxHeight * 0.222,
                            child: Container(
                                height: widget.constraints.maxHeight *
                                    0.2222222222222222,
                                width: widget.constraints.maxWidth *
                                    0.19466666666666665,
                                child: AutoSizeText(
                                  widget.ovrTransactions ?? 'Transactions',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.30000001192092896,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                )),
                          ),
                          Positioned(
                            left: widget.constraints.maxWidth * 0.064,
                            width: widget.constraints.maxWidth * 0.064,
                            top: 0,
                            height: widget.constraints.maxHeight * 0.381,
                            child: Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(),
                                child: Stack(children: [
                                  Positioned(
                                    left: widget.constraints.maxWidth * 0.008,
                                    width: widget.constraints.maxWidth * 0.048,
                                    top: widget.constraints.maxHeight * 0.063,
                                    height:
                                        widget.constraints.maxHeight * 0.312,
                                    child: NavTimerButtonCustom(
                                        child: SvgPicture.asset(
                                      'assets/images/navtimerbuttoncustom.svg',
                                      package: 'genius_wallet',
                                      height: widget.constraints.maxHeight *
                                          0.3123992435515873,
                                      width:
                                          widget.constraints.maxWidth * 0.048,
                                      fit: BoxFit.fill,
                                    )),
                                  ),
                                ])),
                          ),
                        ])),
                  ),
                  Positioned(
                    left: widget.constraints.maxWidth * 0.848,
                    width: widget.constraints.maxWidth * 0.085,
                    top: widget.constraints.maxHeight * 0.175,
                    height: widget.constraints.maxHeight * 0.603,
                    child: Container(
                        decoration: BoxDecoration(),
                        child: Stack(children: [
                          Positioned(
                            left: 0,
                            width: widget.constraints.maxWidth * 0.085,
                            top: widget.constraints.maxHeight * 0.381,
                            height: widget.constraints.maxHeight * 0.222,
                            child: Container(
                                height: widget.constraints.maxHeight *
                                    0.2222222222222222,
                                width: widget.constraints.maxWidth *
                                    0.08533333333333333,
                                child: AutoSizeText(
                                  widget.ovrTrade ?? 'Trade',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.30000001192092896,
                                  ),
                                  textAlign: TextAlign.center,
                                )),
                          ),
                          Positioned(
                            left: widget.constraints.maxWidth * 0.019,
                            width: widget.constraints.maxWidth * 0.048,
                            top: 0,
                            height: widget.constraints.maxHeight * 0.286,
                            child: SvgPicture.asset(
                              'assets/images/group18.svg',
                              package: 'genius_wallet',
                              height: widget.constraints.maxHeight *
                                  0.2857142857142857,
                              width: widget.constraints.maxWidth * 0.048,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ])),
                  ),
                  Positioned(
                    left: widget.constraints.maxWidth * 0.048,
                    width: widget.constraints.maxWidth * 0.163,
                    top: widget.constraints.maxHeight * 0.111,
                    height: widget.constraints.maxHeight * 0.667,
                    child: Container(
                        decoration: BoxDecoration(),
                        child: Stack(children: [
                          Positioned(
                            left: widget.constraints.maxWidth * 0.048,
                            width: widget.constraints.maxWidth * 0.048,
                            top: 0,
                            height: widget.constraints.maxHeight * 0.286,
                            child: SvgPicture.asset(
                              'assets/images/bxsdashboard.svg',
                              package: 'genius_wallet',
                              height: widget.constraints.maxHeight *
                                  0.2857142857142857,
                              width: widget.constraints.maxWidth * 0.048,
                              fit: BoxFit.fill,
                            ),
                          ),
                          Positioned(
                            left: 0,
                            width: widget.constraints.maxWidth * 0.163,
                            top: widget.constraints.maxHeight * 0.444,
                            height: widget.constraints.maxHeight * 0.222,
                            child: Container(
                                height: widget.constraints.maxHeight *
                                    0.2222222222222222,
                                width: widget.constraints.maxWidth *
                                    0.16266666666666665,
                                child: AutoSizeText(
                                  widget.ovrDashboard ?? 'Dashboard',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.30000001192092896,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                )),
                          ),
                        ])),
                  ),
                ])),
          ),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
