// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/trend_line_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CoinStatsCard extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrAmountchanged;
  final Widget? ovrShape;
  final String? ovrCoinName;
  final String? ovrPrice;
  final String? ovrCurrencySymbol;
  const CoinStatsCard(
    this.constraints, {
    Key? key,
    this.ovrAmountchanged,
    this.ovrShape,
    this.ovrCoinName,
    this.ovrPrice,
    this.ovrCurrencySymbol,
  }) : super(key: key);
  @override
  _CoinStatsCard createState() => _CoinStatsCard();
}

class _CoinStatsCard extends State<CoinStatsCard> {
  _CoinStatsCard();

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
                left: 16.0,
                width: 46.0,
                bottom: 19.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 46.0,
                    child: AutoSizeText(
                      widget.ovrAmountchanged ?? '-179.87',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.44999998807907104,
                        color: Color(0xffd0021b),
                      ),
                      textAlign: TextAlign.right,
                    )),
              ),
              Positioned(
                right: 20.359,
                width: 35.0,
                top: 15.672,
                height: 35.0,
                child: Container(
                    decoration: BoxDecoration(),
                    child: Stack(children: [
                      Positioned(
                        left: 0,
                        width: 35.0,
                        top: 0,
                        height: 35.0,
                        child: Container(
                          height: 35.0,
                          width: 35.0,
                          decoration: BoxDecoration(
                            color: Color(0xff3a3c43),
                            borderRadius:
                                BorderRadius.all(Radius.circular(2.0)),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x2dffffff),
                                spreadRadius: 0.0,
                                blurRadius: 0.0,
                                offset: Offset(0.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 9.0,
                        width: 16.0,
                        top: 7.0,
                        height: 22.0,
                        child: widget.ovrShape ??
                            Image.asset(
                              'assets/images/shape.png',
                              package: 'genius_wallet',
                              height: 22.0,
                              width: 16.0,
                              fit: BoxFit.none,
                            ),
                      ),
                    ])),
              ),
              Positioned(
                left: 21.0,
                width: 62.0,
                top: 22.0,
                height: 23.0,
                child: Container(
                    height: 23.0,
                    width: 62.0,
                    child: AutoSizeText(
                      widget.ovrCoinName ?? 'Bitcoin',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 20.0,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.25,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                right: 20.0,
                width: 136.0,
                bottom: 12.0,
                height: 41.0,
                child: Container(
                    height: 41.0,
                    width: 136.0,
                    child: AutoSizeText(
                      widget.ovrPrice ?? '11 329.2',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 35.0,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.3500000238418579,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.right,
                    )),
              ),
              Positioned(
                right: 20.0,
                width: 66.0,
                bottom: 51.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 66.0,
                    child: AutoSizeText(
                      widget.ovrCurrencySymbol ?? 'USD',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2571428716182709,
                        color: Color(0xff3a3c43),
                      ),
                      textAlign: TextAlign.right,
                    )),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.084,
                width: widget.constraints.maxWidth * 0.833,
                top: widget.constraints.maxHeight * 0.307,
                height: widget.constraints.maxHeight * 0.354,
                child: Center(
                    child: Container(
                        height: 68.0,
                        width: 259.0,
                        child: TrendLineCustom(
                            child: SvgPicture.asset(
                          'assets/images/trendlinecustom.svg',
                          package: 'genius_wallet',
                          height: 68.0,
                          width: 259.0,
                          fit: BoxFit.scaleDown,
                        )))),
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
