// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Property1NavbarDashboard extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrTrade;
  final String? ovrTransactions;
  final String? ovrWallets;
  final Widget? ovrVector4;
  final String? ovrDashboard;
  const Property1NavbarDashboard(
    this.constraints, {
    Key? key,
    this.ovrTrade,
    this.ovrTransactions,
    this.ovrWallets,
    this.ovrVector4,
    this.ovrDashboard,
  }) : super(key: key);
  @override
  _Property1NavbarDashboard createState() => _Property1NavbarDashboard();
}

class _Property1NavbarDashboard extends State<Property1NavbarDashboard> {
  _Property1NavbarDashboard();

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
                                      left: 17.0,
                                      width: 18.0,
                                      top: 0,
                                      height: 18.0,
                                      child: widget.ovrVector4 ??
                                          SvgPicture.asset(
                                            'assets/images/vector4.svg',
                                            package: 'genius_wallet',
                                            height: 18.0,
                                            width: 18.0,
                                            fit: BoxFit.none,
                                          ),
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
                                      left: 24.0,
                                      width: 20.0,
                                      top: 0,
                                      height: 20.0,
                                      child: SvgPicture.asset(
                                        'assets/images/ribookletfill.svg',
                                        package: 'genius_wallet',
                                        height: 20.0,
                                        width: 20.0,
                                        fit: BoxFit.none,
                                      ),
                                    ),
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
