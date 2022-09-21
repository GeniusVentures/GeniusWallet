// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CryptoMarketOverview extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrCoinCurrency;
  final String? ovrCurencyValue;
  final String? ovrPercentChange;
  final Widget? ovrMarketTrendline;
  const CryptoMarketOverview(
    this.constraints, {
    Key? key,
    this.ovrCoinCurrency,
    this.ovrCurencyValue,
    this.ovrPercentChange,
    this.ovrMarketTrendline,
  }) : super(key: key);
  @override
  _CryptoMarketOverview createState() => _CryptoMarketOverview();
}

class _CryptoMarketOverview extends State<CryptoMarketOverview> {
  _CryptoMarketOverview();

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
                left: 2.0,
                width: 70.0,
                top: 1.0,
                height: 12.0,
                child: Container(
                    height: 12.0,
                    width: 70.0,
                    child: AutoSizeText(
                      widget.ovrCoinCurrency ?? 'DASH/EUR',
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
                left: 0,
                width: 81.0,
                top: 18.0,
                height: 16.0,
                child: Container(
                    height: 16.0,
                    width: 81.0,
                    child: AutoSizeText(
                      widget.ovrCurencyValue ?? '0.0834  EUR',
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
                left: 75.0,
                width: 56.0,
                top: 0,
                height: 13.0,
                child: Container(
                    height: 13.0,
                    width: 56.0,
                    child: AutoSizeText(
                      widget.ovrPercentChange ?? '1.93%',
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
                left: 0,
                width: 271.0,
                top: 46.0,
                height: 1.0,
                child: Container(
                  height: 1.0,
                  width: 271.0,
                  decoration: BoxDecoration(
                    color: Color(0xff3a3c43),
                  ),
                ),
              ),
              Positioned(
                left: 201.0,
                width: 70.0,
                top: 17.0,
                height: 6.0,
                child: widget.ovrMarketTrendline ??
                    SvgPicture.asset(
                      'assets/images/markettrendline.svg',
                      package: 'genius_wallet',
                      height: 6.0,
                      width: 70.0,
                      fit: BoxFit.none,
                    ),
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
