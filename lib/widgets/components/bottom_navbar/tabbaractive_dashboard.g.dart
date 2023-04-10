// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/nav_wallet_button_custom.dart';
import 'package:genius_wallet/widgets/components/custom/nav_timer_button_custom.dart';

class TabbaractiveDashboard extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrTrade;
  final String? ovrTransactions;
  final String? ovrWallets;
  final String? ovrDashboard;
  const TabbaractiveDashboard(
    this.constraints, {
    Key? key,
    this.ovrTrade,
    this.ovrTransactions,
    this.ovrWallets,
    this.ovrDashboard,
  }) : super(key: key);
  @override
  _TabbaractiveDashboard createState() => _TabbaractiveDashboard();
}

class _TabbaractiveDashboard extends State<TabbaractiveDashboard> {
  _TabbaractiveDashboard();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: Stack(children: [
          Positioned(
            left: 0,
            width: 375.0,
            top: 0,
            height: 63.0,
            child: Container(
                decoration: BoxDecoration(),
                child: Stack(children: [
                  Positioned(
                    left: 0,
                    width: 375.0,
                    top: 0,
                    height: 63.0,
                    child: Container(
                      height: 63.0,
                      width: 375.0,
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
                    width: 375.0,
                    top: 1.0,
                    height: 62.0,
                    child: Container(
                      height: 62.0,
                      width: 375.0,
                      decoration: BoxDecoration(
                        color: Color(0xff1e2025),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18.0,
                    width: 340.0,
                    top: 7.0,
                    height: 42.0,
                    child: Container(
                        decoration: BoxDecoration(),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  height: 42.0,
                                  width: 76.0,
                                  decoration: BoxDecoration(),
                                  child: Stack(children: [
                                    Positioned(
                                      left: 26.0,
                                      width: 18.0,
                                      top: 0,
                                      height: 18.0,
                                      child: SvgPicture.asset(
                                        'assets/images/bxsdashboard.svg',
                                        package: 'genius_wallet',
                                        height: 18.0,
                                        width: 18.0,
                                        fit: BoxFit.none,
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      width: 76.0,
                                      top: 28.0,
                                      height: 14.0,
                                      child: Container(
                                          height: 14.0,
                                          width: 76.0,
                                          child: AutoSizeText(
                                            widget.ovrDashboard ?? 'Dashboard',
                                            style: TextStyle(
                                              fontFamily: 'Roboto',
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing:
                                                  0.30000001192092896,
                                            ),
                                            textAlign: TextAlign.center,
                                          )),
                                    ),
                                  ])),
                              SizedBox(
                                width: 33.0,
                              ),
                              Container(
                                  height: 38.0,
                                  width: 53.0,
                                  decoration: BoxDecoration(),
                                  child: Stack(children: [
                                    Positioned(
                                      left: 18.0,
                                      width: 17.538,
                                      top: 0,
                                      height: 18.0,
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
                                      width: 53.0,
                                      top: 24.0,
                                      height: 14.0,
                                      child: Container(
                                          height: 14.0,
                                          width: 53.0,
                                          child: AutoSizeText(
                                            widget.ovrWallets ?? 'Wallets',
                                            style: TextStyle(
                                              fontFamily: 'Roboto',
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing:
                                                  0.30000001192092896,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          )),
                                    ),
                                  ])),
                              SizedBox(
                                width: 33.0,
                              ),
                              Container(
                                  height: 41.0,
                                  width: 73.0,
                                  decoration: BoxDecoration(),
                                  child: Stack(children: [
                                    Positioned(
                                      left: 0,
                                      width: 73.0,
                                      top: 27.0,
                                      height: 14.0,
                                      child: Container(
                                          height: 14.0,
                                          width: 73.0,
                                          child: AutoSizeText(
                                            widget.ovrTransactions ??
                                                'Transactions',
                                            style: TextStyle(
                                              fontFamily: 'Roboto',
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing:
                                                  0.30000001192092896,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          )),
                                    ),
                                    Positioned(
                                      left: 24.0,
                                      width: 24.0,
                                      top: 0,
                                      height: 24.0,
                                      child: Container(
                                          clipBehavior: Clip.hardEdge,
                                          decoration: BoxDecoration(),
                                          child: Stack(children: [
                                            Positioned(
                                              left:
                                                  widget.constraints.maxWidth *
                                                      0.008,
                                              width:
                                                  widget.constraints.maxWidth *
                                                      0.048,
                                              top:
                                                  widget.constraints.maxHeight *
                                                      0.063,
                                              height:
                                                  widget.constraints.maxHeight *
                                                      0.312,
                                              child: NavTimerButtonCustom(
                                                  child: SvgPicture.asset(
                                                'assets/images/navtimerbuttoncustom.svg',
                                                package: 'genius_wallet',
                                                height: widget
                                                        .constraints.maxHeight *
                                                    0.3123992435515873,
                                                width: widget
                                                        .constraints.maxWidth *
                                                    0.048,
                                                fit: BoxFit.fill,
                                              )),
                                            ),
                                          ])),
                                    ),
                                  ])),
                              SizedBox(
                                width: 33.0,
                              ),
                              Container(
                                  height: 38.0,
                                  width: 39.0,
                                  decoration: BoxDecoration(),
                                  child: Stack(children: [
                                    Positioned(
                                      left: 0,
                                      width: 39.0,
                                      top: 24.0,
                                      height: 14.0,
                                      child: Container(
                                          height: 14.0,
                                          width: 39.0,
                                          child: AutoSizeText(
                                            widget.ovrTrade ?? 'Trade',
                                            style: TextStyle(
                                              fontFamily: 'Roboto',
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing:
                                                  0.30000001192092896,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          )),
                                    ),
                                    Positioned(
                                      left: 11.0,
                                      width: 18.0,
                                      top: 0,
                                      height: 18.0,
                                      child: SvgPicture.asset(
                                        'assets/images/group18.svg',
                                        package: 'genius_wallet',
                                        height: 18.0,
                                        width: 18.0,
                                        fit: BoxFit.none,
                                      ),
                                    ),
                                  ])),
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
