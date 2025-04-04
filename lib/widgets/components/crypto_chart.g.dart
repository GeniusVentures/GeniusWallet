// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/date_selector.g.dart';
import 'package:genius_wallet/widgets/components/custom/chart_options_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/price_custom.dart';
import 'package:genius_wallet/widgets/components/custom/dateselector_custom.dart';
import 'package:genius_wallet/widgets/components/custom/trendline_with_axes_custom.dart';
import 'package:genius_wallet/widgets/components/custom/trendline_hover_custom.dart';

class CryptoChart extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrBitcoinChart;
  final String? ovrTime;
  final String? ovr114;
  final String? ovr975600USD;
  final String? ovrBTCUSD;
  final String? ovr20nov;
  final String? ovr6nov;
  final Widget? ovrPath4;
  final String? ovr23oct;
  final String? ovr25k;
  final String? ovr20k;
  final String? ovr15k;
  final String? ovr10k;
  final String? ovr5k;
  final String? ovr0k;
  final String? ovrBitcoinPrice723;
  final String? ovrWebnesdayNov082;
  final Widget? ovrCombinedShape;
  const CryptoChart(
    this.constraints, {
    Key? key,
    this.ovrBitcoinChart,
    this.ovrTime,
    this.ovr114,
    this.ovr975600USD,
    this.ovrBTCUSD,
    this.ovr20nov,
    this.ovr6nov,
    this.ovrPath4,
    this.ovr23oct,
    this.ovr25k,
    this.ovr20k,
    this.ovr15k,
    this.ovr10k,
    this.ovr5k,
    this.ovr0k,
    this.ovrBitcoinPrice723,
    this.ovrWebnesdayNov082,
    this.ovrCombinedShape,
  }) : super(key: key);
  @override
  _CryptoChart createState() => _CryptoChart();
}

class _CryptoChart extends State<CryptoChart> {
  _CryptoChart();

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
                right: 18.0,
                width: 4.0,
                top: 32.0,
                height: 16.0,
                child: ChartOptionsCustom(
                    child: SvgPicture.asset(
                  'assets/images/chartoptionscustom.svg',
                  package: 'genius_wallet',
                  height: 16.0,
                  width: 4.0,
                  fit: BoxFit.none,
                )),
              ),
              Positioned(
                left: 18.0,
                width: 175.0,
                top: 23.0,
                height: 35.0,
                child: Container(
                    height: 35.0,
                    width: 175.0,
                    child: AutoSizeText(
                      widget.ovrBitcoinChart ?? 'Bitcoin Chart',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 30.0,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
              Positioned(
                right: 42.0,
                width: 37.0,
                top: 29.0,
                height: 23.0,
                child: Container(
                    decoration: BoxDecoration(),
                    child: Stack(children: [
                      Positioned(
                        left: 0,
                        width: 37.0,
                        top: 0,
                        height: 23.0,
                        child: Container(
                          height: 23.0,
                          width: 37.0,
                          decoration: BoxDecoration(
                            color: Color(0xff4c4d55),
                            borderRadius:
                                BorderRadius.all(Radius.circular(14.0)),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 6.0,
                        width: 24.0,
                        top: 4.0,
                        height: 14.0,
                        child: Container(
                            height: 14.0,
                            width: 24.0,
                            child: AutoSizeText(
                              widget.ovrTime ?? '3m',
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
                    ])),
              ),
              Positioned(
                left: 20.0,
                width: 272.0,
                top: 71.0,
                height: 52.0,
                child: PriceCustom(
                    child: Container(
                        decoration: BoxDecoration(),
                        child: Stack(children: [
                          Positioned(
                            left: 0,
                            width: 137.0,
                            top: 0,
                            height: 30.0,
                            child: Container(
                                height: 30.0,
                                width: 137.0,
                                child: AutoSizeText(
                                  widget.ovrBTCUSD ?? 'BTC/USD',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.25714290142059326,
                                    color: Color(0xff3a3c43),
                                  ),
                                  textAlign: TextAlign.left,
                                )),
                          ),
                          Positioned(
                            right: 0,
                            width: 163.0,
                            top: 29.0,
                            height: 23.0,
                            child: Container(
                                height: 23.0,
                                width: 163.0,
                                child: AutoSizeText(
                                  widget.ovr975600USD ?? '9,756.00  USD',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.6000000238418579,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.right,
                                )),
                          ),
                          Positioned(
                            left: 51.0,
                            width: 53.0,
                            top: 34.0,
                            height: 14.0,
                            child: Container(
                                height: 14.0,
                                width: 53.0,
                                child: AutoSizeText(
                                  widget.ovr114 ?? '-1.14%',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.44999998807907104,
                                    color: Color(0xffd0021b),
                                  ),
                                  textAlign: TextAlign.left,
                                )),
                          ),
                        ]))),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.064,
                width: widget.constraints.maxWidth * 0.871,
                top: 159.0,
                height: 29.0,
                child: Center(
                    child: Container(
                        height: 29.0,
                        width: 271.0,
                        child: DateselectorCustom(child:
                            LayoutBuilder(builder: (context, constraints) {
                          return DateSelector(
                            constraints,
                            ovrfrom: 'from',
                            ovrOct132017: 'Oct 13, 2017',
                            ovrTo: 'To',
                            ovrEndDate: 'Dec 13, 2017',
                          );
                        })))),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.019,
                width: widget.constraints.maxWidth * 0.923,
                top: widget.constraints.maxHeight * 0.322,
                height: widget.constraints.maxHeight * 0.613,
                child: Center(
                    child: Container(
                        height:
                            widget.constraints.maxHeight * 0.6134453781512605,
                        width: 287.0,
                        child: TrendlineWithAxesCustom(
                            child: Container(
                                decoration: BoxDecoration(),
                                child: Stack(children: [
                                  Positioned(
                                    left: 0,
                                    width: 39.0,
                                    top: 391.0,
                                    height: 12.0,
                                    child: Container(
                                        height: 12.0,
                                        width: 39.0,
                                        child: AutoSizeText(
                                          widget.ovr0k ?? '0k',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.25,
                                            color: Color(0xff606166),
                                          ),
                                          textAlign: TextAlign.center,
                                        )),
                                  ),
                                  Positioned(
                                    left: 0,
                                    width: 39.0,
                                    top: 313.0,
                                    height: 12.0,
                                    child: Container(
                                        height: 12.0,
                                        width: 39.0,
                                        child: AutoSizeText(
                                          widget.ovr5k ?? '5k',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.25,
                                            color: Color(0xff606166),
                                          ),
                                          textAlign: TextAlign.center,
                                        )),
                                  ),
                                  Positioned(
                                    left: 0,
                                    width: 39.0,
                                    top: 236.0,
                                    height: 12.0,
                                    child: Container(
                                        height: 12.0,
                                        width: 39.0,
                                        child: AutoSizeText(
                                          widget.ovr10k ?? '10k',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.25,
                                            color: Color(0xff606166),
                                          ),
                                          textAlign: TextAlign.center,
                                        )),
                                  ),
                                  Positioned(
                                    left: 0,
                                    width: 39.0,
                                    top: 158.0,
                                    height: 12.0,
                                    child: Container(
                                        height: 12.0,
                                        width: 39.0,
                                        child: AutoSizeText(
                                          widget.ovr15k ?? '15k',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.25,
                                            color: Color(0xff606166),
                                          ),
                                          textAlign: TextAlign.center,
                                        )),
                                  ),
                                  Positioned(
                                    left: 0,
                                    width: 39.0,
                                    top: 80.0,
                                    height: 12.0,
                                    child: Container(
                                        height: 12.0,
                                        width: 39.0,
                                        child: AutoSizeText(
                                          widget.ovr20k ?? '20k',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.25,
                                            color: Color(0xff606166),
                                          ),
                                          textAlign: TextAlign.center,
                                        )),
                                  ),
                                  Positioned(
                                    left: 1.0,
                                    width: 39.0,
                                    top: 0,
                                    height: 12.0,
                                    child: Container(
                                        height: 12.0,
                                        width: 39.0,
                                        child: AutoSizeText(
                                          widget.ovr25k ?? '25k',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.25,
                                            color: Color(0xff606166),
                                          ),
                                          textAlign: TextAlign.center,
                                        )),
                                  ),
                                  Positioned(
                                    left: 58.0,
                                    width: 39.0,
                                    top: 426.0,
                                    height: 12.0,
                                    child: Container(
                                        height: 12.0,
                                        width: 39.0,
                                        child: AutoSizeText(
                                          widget.ovr23oct ?? '23 oct',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.25,
                                            color: Color(0xff606166),
                                          ),
                                          textAlign: TextAlign.center,
                                        )),
                                  ),
                                  Positioned(
                                    left: 44.0,
                                    width: 241.0,
                                    top: 6.0,
                                    height: 1.0,
                                    child: Container(
                                      height: 1.0,
                                      width: 241.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 44.0,
                                    width: 241.0,
                                    top: 85.0,
                                    height: 1.0,
                                    child: Container(
                                      height: 1.0,
                                      width: 241.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 44.0,
                                    width: 241.0,
                                    top: 163.0,
                                    height: 1.0,
                                    child: Container(
                                      height: 1.0,
                                      width: 241.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 44.0,
                                    width: 241.0,
                                    top: 241.0,
                                    height: 1.0,
                                    child: Container(
                                      height: 1.0,
                                      width: 241.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 44.0,
                                    width: 241.0,
                                    top: 320.0,
                                    height: 1.0,
                                    child: Container(
                                      height: 1.0,
                                      width: 241.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 44.0,
                                    width: 241.0,
                                    top: 398.0,
                                    height: 1.0,
                                    child: Container(
                                      height: 1.0,
                                      width: 241.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 74.0,
                                    width: 1.0,
                                    top: 399.0,
                                    height: 8.0,
                                    child: Container(
                                      height: 8.0,
                                      width: 1.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 51.0,
                                    width: 222.0,
                                    top: 148.0,
                                    height: 187.0,
                                    child: widget.ovrPath4 ??
                                        SvgPicture.asset(
                                          'assets/images/path4.svg',
                                          package: 'genius_wallet',
                                          height: 187.0,
                                          width: 222.0,
                                          fit: BoxFit.none,
                                        ),
                                  ),
                                  Positioned(
                                    left: 149.0,
                                    width: 39.0,
                                    top: 426.0,
                                    height: 12.0,
                                    child: Container(
                                        height: 12.0,
                                        width: 39.0,
                                        child: AutoSizeText(
                                          widget.ovr6nov ?? '6 nov',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.25,
                                            color: Color(0xff606166),
                                          ),
                                          textAlign: TextAlign.center,
                                        )),
                                  ),
                                  Positioned(
                                    left: 165.0,
                                    width: 1.0,
                                    top: 399.0,
                                    height: 8.0,
                                    child: Container(
                                      height: 8.0,
                                      width: 1.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 237.0,
                                    width: 50.0,
                                    top: 426.0,
                                    height: 12.0,
                                    child: Container(
                                        height: 12.0,
                                        width: 50.0,
                                        child: AutoSizeText(
                                          widget.ovr20nov ?? '20 nov',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.25,
                                            color: Color(0xff606166),
                                          ),
                                          textAlign: TextAlign.center,
                                        )),
                                  ),
                                  Positioned(
                                    left: 265.0,
                                    width: 1.0,
                                    top: 399.0,
                                    height: 8.0,
                                    child: Container(
                                      height: 8.0,
                                      width: 1.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 183.0,
                                    width: 1.0,
                                    top: 8.0,
                                    height: 391.0,
                                    child: Container(
                                      height: 391.0,
                                      width: 1.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff4c4d55),
                                      ),
                                    ),
                                  ),
                                ]))))),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.28,
                width: widget.constraints.maxWidth * 0.662,
                top: widget.constraints.maxHeight * 0.619,
                height: widget.constraints.maxHeight * 0.081,
                child: Center(
                    child: Container(
                        height:
                            widget.constraints.maxHeight * 0.08123249299719888,
                        width: 206.0,
                        child: TrendlineHoverCustom(
                            child: Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(),
                                child: Stack(children: [
                                  Positioned(
                                    left: 0,
                                    width: 206.0,
                                    top: 0,
                                    height: widget.constraints.maxHeight * 0.08,
                                    child: widget.ovrCombinedShape ??
                                        Image.asset(
                                          'assets/images/combinedshape.png',
                                          package: 'genius_wallet',
                                          height: widget.constraints.maxHeight *
                                              0.07993143546481092,
                                          width: 206.0,
                                          fit: BoxFit.fill,
                                        ),
                                  ),
                                  Positioned(
                                    left: 42.5,
                                    width: 120.0,
                                    top: widget.constraints.maxHeight * 0.041,
                                    height:
                                        widget.constraints.maxHeight * 0.017,
                                    child: Center(
                                        child: Container(
                                            height: 12.0,
                                            width: 120.0,
                                            child: AutoSizeText(
                                              widget.ovrWebnesdayNov082 ??
                                                  'Webnesday, Nov 08, 2017',
                                              style: TextStyle(
                                                fontFamily: 'Roboto',
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: 0.25,
                                                color: Color(0xff42434b),
                                              ),
                                              textAlign: TextAlign.center,
                                            ))),
                                  ),
                                  Positioned(
                                    left: 25.5,
                                    width: 155.0,
                                    top: widget.constraints.maxHeight * 0.01,
                                    height:
                                        widget.constraints.maxHeight * 0.022,
                                    child: Center(
                                        child: Container(
                                            height: 16.0,
                                            width: 155.0,
                                            child: AutoSizeText(
                                              widget.ovrBitcoinPrice723 ??
                                                  'Bitcoin Price: \$7,230.69',
                                              style: TextStyle(
                                                fontFamily: 'Roboto',
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w400,
                                                letterSpacing:
                                                    0.32307690382003784,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ))),
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
