// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/desktop/custom/nav_news_button_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:genius_wallet/widgets/desktop/custom/nav_dashboard_button_custom.dart';
import 'package:genius_wallet/widgets/desktop/custom/nav_wallet_button_custom.dart';
import 'package:genius_wallet/widgets/desktop/custom/nav_stats_button_custom.dart';
import 'package:genius_wallet/widgets/desktop/custom/nav_timer_button_custom.dart';
import 'package:genius_wallet/widgets/desktop/custom/nav_calculator_button_custom.dart';
import 'package:genius_wallet/widgets/desktop/custom/nav_calendar_button_custom.dart';
import 'package:genius_wallet/widgets/desktop/custom/alerts_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class NavNews extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrTradeDesktopIconUnselected;
  final Widget? ovrGeniusAppbarLogo;
  final Widget? ovrMask;
  final Widget? ovrMask2;
  final String? ovr1;
  final Widget? ovrOval;
  const NavNews(
    this.constraints, {
    Key? key,
    this.ovrTradeDesktopIconUnselected,
    this.ovrGeniusAppbarLogo,
    this.ovrMask,
    this.ovrMask2,
    this.ovr1,
    this.ovrOval,
  }) : super(key: key);
  @override
  _NavNews createState() => _NavNews();
}

class _NavNews extends State<NavNews> {
  _NavNews();

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
                width: widget.constraints.maxWidth * 0.999,
                top: 0,
                height: widget.constraints.maxHeight * 1.0,
                child: Container(
                  height: widget.constraints.maxHeight * 1.0,
                  width: widget.constraints.maxWidth * 0.9993060374739764,
                  decoration: BoxDecoration(
                    color: Color(0xff1d2024),
                  ),
                ),
              ),
              Positioned(
                left: 37.953,
                width: 15.014,
                top: 520.229,
                height: 15.2,
                child: NavNewsButtonCustom(
                    child: SvgPicture.asset(
                  'assets/images/navnewsbuttoncustom.svg',
                  package: 'genius_wallet',
                  height: 15.199951171875,
                  width: 15.013671875,
                  fit: BoxFit.none,
                )),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.422,
                width: widget.constraints.maxWidth * 0.178,
                top: widget.constraints.maxHeight * 0.518,
                height: widget.constraints.maxHeight * 0.014,
                child: widget.ovrTradeDesktopIconUnselected ??
                    SvgPicture.asset(
                      'assets/images/tradedesktopiconunselected.svg',
                      package: 'genius_wallet',
                      height:
                          widget.constraints.maxHeight * 0.01432408236347359,
                      width: widget.constraints.maxWidth * 0.17765440666204024,
                      fit: BoxFit.fill,
                    ),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.278,
                width: widget.constraints.maxWidth * 0.422,
                top: widget.constraints.maxHeight * 0.046,
                height: widget.constraints.maxHeight * 0.034,
                child: widget.ovrGeniusAppbarLogo ??
                    Image.asset(
                      'assets/images/geniusappbarlogo.png',
                      package: 'genius_wallet',
                      height:
                          widget.constraints.maxHeight * 0.03401969561324977,
                      width: widget.constraints.maxWidth * 0.4219292158223456,
                      fit: BoxFit.fill,
                    ),
              ),
              Positioned(
                left: 0,
                right: 0.063,
                top: 498.0,
                height: 60.317,
                child: Container(
                  height: 60.3173828125,
                  width: widget.constraints.maxWidth * 0.9993060374739764,
                  decoration: BoxDecoration(
                    color: Color(0xff2a2b31),
                  ),
                ),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.42,
                width: widget.constraints.maxWidth * 0.169,
                top: widget.constraints.maxHeight * 0.152,
                height: widget.constraints.maxHeight * 0.014,
                child: NavDashboardButtonCustom(
                    child: Image.asset(
                  'assets/images/navdashboardbuttoncustom.png',
                  package: 'genius_wallet',
                  height: widget.constraints.maxHeight * 0.014064641967882721,
                  width: widget.constraints.maxWidth * 0.16877385496183206,
                  fit: BoxFit.fill,
                )),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.42,
                width: widget.constraints.maxWidth * 0.169,
                top: widget.constraints.maxHeight * 0.205,
                height: widget.constraints.maxHeight * 0.014,
                child: NavWalletButtonCustom(
                    child: Image.asset(
                  'assets/images/navwalletbuttoncustom.png',
                  package: 'genius_wallet',
                  height: widget.constraints.maxHeight * 0.01396606773164727,
                  width: widget.constraints.maxWidth * 0.16877385496183206,
                  fit: BoxFit.fill,
                )),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.42,
                width: widget.constraints.maxWidth * 0.169,
                top: widget.constraints.maxHeight * 0.257,
                height: widget.constraints.maxHeight * 0.014,
                child: NavStatsButtonCustom(
                    child: Image.asset(
                  'assets/images/navstatsbuttoncustom.png',
                  package: 'genius_wallet',
                  height: widget.constraints.maxHeight * 0.01360783453166965,
                  width: widget.constraints.maxWidth * 0.16877385496183206,
                  fit: BoxFit.fill,
                )),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.425,
                width: widget.constraints.maxWidth * 0.16,
                top: widget.constraints.maxHeight * 0.361,
                height: widget.constraints.maxHeight * 0.014,
                child: NavTimerButtonCustom(
                    child: Image.asset(
                  'assets/images/navtimerbuttoncustom.png',
                  package: 'genius_wallet',
                  height: widget.constraints.maxHeight * 0.014101361417300807,
                  width: widget.constraints.maxWidth * 0.15994751908396945,
                  fit: BoxFit.fill,
                )),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.421,
                width: widget.constraints.maxWidth * 0.168,
                top: widget.constraints.maxHeight * 0.413,
                height: widget.constraints.maxHeight * 0.014,
                child: NavCalculatorButtonCustom(
                    child: Image.asset(
                  'assets/images/navcalculatorbuttoncustom.png',
                  package: 'genius_wallet',
                  height: widget.constraints.maxHeight * 0.01396606773164727,
                  width: widget.constraints.maxWidth * 0.16765700902151284,
                  fit: BoxFit.fill,
                )),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.42,
                width: widget.constraints.maxWidth * 0.169,
                top: widget.constraints.maxHeight * 0.309,
                height: widget.constraints.maxHeight * 0.014,
                child: NavCalendarButtonCustom(
                    child: Image.asset(
                  'assets/images/navcalendarbuttoncustom.png',
                  package: 'genius_wallet',
                  height: widget.constraints.maxHeight * 0.01396606773164727,
                  width: widget.constraints.maxWidth * 0.16877385496183206,
                  fit: BoxFit.fill,
                )),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.3,
                width: widget.constraints.maxWidth * 0.455,
                top: widget.constraints.maxHeight * 0.611,
                height: widget.constraints.maxHeight * 0.037,
                child: AlertsCustom(
                    child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(),
                        child: Stack(children: [
                          Positioned(
                            left: 0,
                            width: widget.constraints.maxWidth * 0.378,
                            top: widget.constraints.maxHeight * 0.006,
                            height: widget.constraints.maxHeight * 0.03,
                            child: Container(
                              height: widget.constraints.maxHeight *
                                  0.03043867502238138,
                              width: widget.constraints.maxWidth *
                                  0.37751561415683554,
                              decoration: BoxDecoration(
                                color: Color(0xff4c4d55),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2.0)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: widget.constraints.maxWidth * 0.289,
                            width: widget.constraints.maxWidth * 0.167,
                            top: 0,
                            height: widget.constraints.maxHeight * 0.013,
                            child: widget.ovrOval ??
                                Image.asset(
                                  'assets/images/oval.png',
                                  package: 'genius_wallet',
                                  height: widget.constraints.maxHeight *
                                      0.01342882721575649,
                                  width: widget.constraints.maxWidth *
                                      0.16655100624566274,
                                  fit: BoxFit.fill,
                                ),
                          ),
                          Positioned(
                            left: widget.constraints.maxWidth * 0.333,
                            width: widget.constraints.maxWidth * 0.078,
                            top: widget.constraints.maxHeight * 0.001,
                            height: widget.constraints.maxHeight * 0.012,
                            child: Center(
                                child: Container(
                                    height: 13.0,
                                    width: widget.constraints.maxWidth *
                                        0.0777238029146426,
                                    child: AutoSizeText(
                                      widget.ovr1 ?? '1',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 11.0,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.13750000298023224,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ))),
                          ),
                          Positioned(
                            left: widget.constraints.maxWidth * 0.078,
                            width: widget.constraints.maxWidth * 0.222,
                            top: widget.constraints.maxHeight * 0.013,
                            height: widget.constraints.maxHeight * 0.018,
                            child: widget.ovrMask2 ??
                                Image.asset(
                                  'assets/images/mask2.png',
                                  package: 'genius_wallet',
                                  height: widget.constraints.maxHeight *
                                      0.017905102954341987,
                                  width: widget.constraints.maxWidth *
                                      0.2220680083275503,
                                  fit: BoxFit.fill,
                                ),
                          ),
                          Positioned(
                            left: widget.constraints.maxWidth * 0.078,
                            width: widget.constraints.maxWidth * 0.222,
                            top: widget.constraints.maxHeight * 0.013,
                            height: widget.constraints.maxHeight * 0.018,
                            child: widget.ovrMask ??
                                Image.asset(
                                  'assets/images/mask.png',
                                  package: 'genius_wallet',
                                  height: widget.constraints.maxHeight *
                                      0.017905102954341987,
                                  width: widget.constraints.maxWidth *
                                      0.2220680083275503,
                                  fit: BoxFit.fill,
                                ),
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
