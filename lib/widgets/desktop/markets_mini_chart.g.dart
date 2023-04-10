// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/desktop/custom/usd_text_button_tab_custom.dart';
import 'package:genius_wallet/widgets/desktop/custom/eur_text_button_tab_custom.dart';
import 'package:genius_wallet/widgets/desktop/custom/btc_text_button_tab_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MarketsMiniChart extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrPath10;
  final Widget? ovrPath5;
  final Widget? ovrPath2;
  final Widget? ovrPath8;
  final String? ovr175;
  final String? ovr1143518EUR;
  final String? ovrBTCEUR;
  final String? ovr048;
  final String? ovr19748EUR;
  final String? ovrLTCEUR;
  final String? ovr114;
  final String? ovr108791EUR;
  final String? ovrETHEUR;
  final String? ovr193;
  final String? ovr00834EUR;
  final String? ovrDASHEUR;
  final String? ovrMarkets;
  const MarketsMiniChart(
    this.constraints, {
    Key? key,
    this.ovrPath10,
    this.ovrPath5,
    this.ovrPath2,
    this.ovrPath8,
    this.ovr175,
    this.ovr1143518EUR,
    this.ovrBTCEUR,
    this.ovr048,
    this.ovr19748EUR,
    this.ovrLTCEUR,
    this.ovr114,
    this.ovr108791EUR,
    this.ovrETHEUR,
    this.ovr193,
    this.ovr00834EUR,
    this.ovrDASHEUR,
    this.ovrMarkets,
  }) : super(key: key);
  @override
  _MarketsMiniChart createState() => _MarketsMiniChart();
}

class _MarketsMiniChart extends State<MarketsMiniChart> {
  _MarketsMiniChart();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: Stack(children: [
          Positioned(
            left: 0,
            width: 234.0,
            top: 0,
            height: 313.0,
            child: Container(
                decoration: BoxDecoration(),
                child: Stack(children: [
                  Positioned(
                    left: 0,
                    width: 234.0,
                    top: 0,
                    height: 313.0,
                    child: Container(
                      height: 313.0,
                      width: 234.0,
                      decoration: BoxDecoration(
                        color: Color(0xff1e2025),
                        borderRadius: BorderRadius.all(Radius.circular(2.0)),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 26.0,
                    width: 60.0,
                    top: 15.0,
                    height: 19.0,
                    child: Container(
                        height: 19.0,
                        width: 60.0,
                        child: AutoSizeText(
                          widget.ovrMarkets ?? 'Markets',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.0,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        )),
                  ),
                  Positioned(
                    left: 127.5,
                    width: 23.0,
                    top: 18.0,
                    height: 13.0,
                    child: UsdTextButtonTabCustom(
                        child: AutoSizeText(
                      'USD',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.0,
                        color: Color(0xff606166),
                      ),
                      textAlign: TextAlign.center,
                    )),
                  ),
                  Positioned(
                    left: 158.75,
                    width: 22.0,
                    top: 18.0,
                    height: 13.0,
                    child: EurTextButtonTabCustom(
                        child: AutoSizeText(
                      'EUR',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
                  ),
                  Positioned(
                    left: 190.0,
                    width: 22.0,
                    top: 18.0,
                    height: 13.0,
                    child: BtcTextButtonTabCustom(
                        child: AutoSizeText(
                      'BTC',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.0,
                        color: Color(0xff606166),
                      ),
                      textAlign: TextAlign.center,
                    )),
                  ),
                  Positioned(
                    left: 31.5,
                    width: 51.0,
                    top: 66.0,
                    height: 12.0,
                    child: Container(
                        height: 12.0,
                        width: 51.0,
                        child: AutoSizeText(
                          widget.ovrDASHEUR ?? 'DASH/EUR',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 10.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.30000001192092896,
                            color: Color(0xff606166),
                          ),
                          textAlign: TextAlign.center,
                        )),
                  ),
                  Positioned(
                    left: 29.5,
                    width: 81.0,
                    top: 83.0,
                    height: 16.0,
                    child: Container(
                        height: 16.0,
                        width: 81.0,
                        child: AutoSizeText(
                          widget.ovr00834EUR ?? '0.0834  EUR',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.30000001192092896,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.left,
                        )),
                  ),
                  Positioned(
                    left: 90.0,
                    width: 32.0,
                    top: 65.0,
                    height: 13.0,
                    child: Container(
                        height: 13.0,
                        width: 32.0,
                        child: AutoSizeText(
                          widget.ovr193 ?? '1.93%',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 11.0,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.4124999940395355,
                            color: Color(0xff4c4d55),
                          ),
                          textAlign: TextAlign.center,
                        )),
                  ),
                  Positioned(
                    left: 25.0,
                    width: 182.0,
                    top: 111.0,
                    height: 1.0,
                    child: Container(
                      height: 1.0,
                      width: 182.0,
                      decoration: BoxDecoration(
                        color: Color(0xff3a3c43),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 30.5,
                    width: 44.0,
                    top: 131.0,
                    height: 12.0,
                    child: Container(
                        height: 12.0,
                        width: 44.0,
                        child: AutoSizeText(
                          widget.ovrETHEUR ?? 'ETH/EUR',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 10.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.30000001192092896,
                            color: Color(0xff606166),
                          ),
                          textAlign: TextAlign.center,
                        )),
                  ),
                  Positioned(
                    left: 29.5,
                    width: 93.0,
                    top: 148.0,
                    height: 16.0,
                    child: Container(
                        height: 16.0,
                        width: 93.0,
                        child: AutoSizeText(
                          widget.ovr108791EUR ?? '1,087.91  EUR',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.30000001192092896,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.left,
                        )),
                  ),
                  Positioned(
                    left: 84.5,
                    width: 35.0,
                    top: 130.0,
                    height: 13.0,
                    child: Container(
                        height: 13.0,
                        width: 35.0,
                        child: AutoSizeText(
                          widget.ovr114 ?? '-1.14%',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 11.0,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.4124999940395355,
                            color: Color(0xff4c4d55),
                          ),
                          textAlign: TextAlign.center,
                        )),
                  ),
                  Positioned(
                    left: 25.0,
                    width: 182.0,
                    top: 176.0,
                    height: 1.0,
                    child: Container(
                      height: 1.0,
                      width: 182.0,
                      decoration: BoxDecoration(
                        color: Color(0xff3a3c43),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 30.5,
                    width: 42.0,
                    top: 195.0,
                    height: 12.0,
                    child: Container(
                        height: 12.0,
                        width: 42.0,
                        child: AutoSizeText(
                          widget.ovrLTCEUR ?? 'LTC/EUR',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 10.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.30000001192092896,
                            color: Color(0xff606166),
                          ),
                          textAlign: TextAlign.center,
                        )),
                  ),
                  Positioned(
                    left: 29.5,
                    width: 81.0,
                    top: 212.0,
                    height: 16.0,
                    child: Container(
                        height: 16.0,
                        width: 81.0,
                        child: AutoSizeText(
                          widget.ovr19748EUR ?? '197.48  EUR',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.30000001192092896,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.left,
                        )),
                  ),
                  Positioned(
                    left: 83.5,
                    width: 35.0,
                    top: 194.0,
                    height: 13.0,
                    child: Container(
                        height: 13.0,
                        width: 35.0,
                        child: AutoSizeText(
                          widget.ovr048 ?? '-0.48%',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 11.0,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.4124999940395355,
                            color: Color(0xff4c4d55),
                          ),
                          textAlign: TextAlign.center,
                        )),
                  ),
                  Positioned(
                    left: 25.0,
                    width: 182.0,
                    top: 240.0,
                    height: 1.0,
                    child: Container(
                      height: 1.0,
                      width: 182.0,
                      decoration: BoxDecoration(
                        color: Color(0xff3a3c43),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 31.5,
                    width: 43.0,
                    top: 260.0,
                    height: 12.0,
                    child: Container(
                        height: 12.0,
                        width: 43.0,
                        child: AutoSizeText(
                          widget.ovrBTCEUR ?? 'BTC/EUR',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 10.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.30000001192092896,
                            color: Color(0xff606166),
                          ),
                          textAlign: TextAlign.center,
                        )),
                  ),
                  Positioned(
                    left: 29.5,
                    width: 97.0,
                    top: 277.0,
                    height: 16.0,
                    child: Container(
                        height: 16.0,
                        width: 97.0,
                        child: AutoSizeText(
                          widget.ovr1143518EUR ?? '11,435.18 EUR',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.30000001192092896,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.left,
                        )),
                  ),
                  Positioned(
                    left: 84.5,
                    width: 32.0,
                    top: 259.0,
                    height: 13.0,
                    child: Container(
                        height: 13.0,
                        width: 32.0,
                        child: AutoSizeText(
                          widget.ovr175 ?? '1.75%',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 11.0,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.4124999940395355,
                            color: Color(0xff4c4d55),
                          ),
                          textAlign: TextAlign.center,
                        )),
                  ),
                  Positioned(
                    left: 140.811,
                    width: 70.0,
                    top: 82.0,
                    height: 5.793,
                    child: widget.ovrPath8 ??
                        SvgPicture.asset(
                          'assets/images/path8.svg',
                          package: 'genius_wallet',
                          height: 5.792724609375,
                          width: 70.0,
                          fit: BoxFit.none,
                        ),
                  ),
                  Positioned(
                    left: 140.811,
                    width: 70.0,
                    top: 126.977,
                    height: 23.5,
                    child: widget.ovrPath2 ??
                        SvgPicture.asset(
                          'assets/images/path2.svg',
                          package: 'genius_wallet',
                          height: 23.500244140625,
                          width: 70.0,
                          fit: BoxFit.none,
                        ),
                  ),
                  Positioned(
                    left: 140.811,
                    width: 70.0,
                    top: 193.456,
                    height: 19.436,
                    child: widget.ovrPath5 ??
                        SvgPicture.asset(
                          'assets/images/path5.svg',
                          package: 'genius_wallet',
                          height: 19.435791015625,
                          width: 70.0,
                          fit: BoxFit.none,
                        ),
                  ),
                  Positioned(
                    left: 139.0,
                    width: 70.0,
                    top: 255.0,
                    height: 29.84,
                    child: widget.ovrPath10 ??
                        SvgPicture.asset(
                          'assets/images/path10.svg',
                          package: 'genius_wallet',
                          height: 29.840087890625,
                          width: 70.0,
                          fit: BoxFit.none,
                        ),
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
