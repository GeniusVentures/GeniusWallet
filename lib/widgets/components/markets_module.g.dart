// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/crypto_market_overview.g.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/currency_toggle_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MarketsModule extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrMarkets;
  final String? ovrBTC;
  final String? ovrEUR;
  final String? ovrUSD;
  final Widget? ovrCryptoMarketOverview;
  const MarketsModule(
    this.constraints, {
    Key? key,
    this.ovrMarkets,
    this.ovrBTC,
    this.ovrEUR,
    this.ovrUSD,
    this.ovrCryptoMarketOverview,
  }) : super(key: key);
  @override
  _MarketsModule createState() => _MarketsModule();
}

class _MarketsModule extends State<MarketsModule> {
  _MarketsModule();

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
                    color: Color(0xff2a2b31),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
              Positioned(
                left: 17.0,
                width: 60.0,
                top: 21.0,
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
                right: 18.0,
                width: 95.0,
                top: 24.0,
                height: 13.0,
                child: CurrencyToggleCustom(
                    child: Container(
                        decoration: BoxDecoration(),
                        child: Stack(children: [
                          Positioned(
                            left: 0,
                            width: 28.0,
                            top: 0,
                            height: 13.0,
                            child: Container(
                                height: 13.0,
                                width: 28.0,
                                child: AutoSizeText(
                                  widget.ovrUSD ?? 'USD',
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
                            left: 34.0,
                            width: 28.0,
                            top: 0,
                            height: 13.0,
                            child: Container(
                                height: 13.0,
                                width: 28.0,
                                child: AutoSizeText(
                                  widget.ovrEUR ?? 'EUR',
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
                            left: 67.0,
                            width: 28.0,
                            top: 0,
                            height: 13.0,
                            child: Container(
                                height: 13.0,
                                width: 28.0,
                                child: AutoSizeText(
                                  widget.ovrBTC ?? 'BTC',
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
                        ]))),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.064,
                width: widget.constraints.maxWidth * 0.871,
                top: 65.0,
                height: 47.0,
                child: LayoutBuilder(builder: (context, constraints) {
                  return CryptoMarketOverview(
                    constraints,
                    ovrCoinCurrency: 'DASH/EUR',
                    ovrCurencyValue: '0.0834  EUR',
                    ovrPercentChange: '1.93%',
                    ovrMarketTrendline: SvgPicture.asset(
                      'assets/images/markettrendline.svg',
                      package: 'genius_wallet',
                      height: 6.0,
                      width: 70.0,
                      fit: BoxFit.none,
                    ),
                  );
                }),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.064,
                width: widget.constraints.maxWidth * 0.871,
                top: 130.0,
                height: 47.0,
                child: LayoutBuilder(builder: (context, constraints) {
                  return CryptoMarketOverview(
                    constraints,
                    ovrCoinCurrency: 'DASH/EUR',
                    ovrCurencyValue: '0.0834  EUR',
                    ovrPercentChange: '1.93%',
                    ovrMarketTrendline: SvgPicture.asset(
                      'assets/images/markettrendline.svg',
                      package: 'genius_wallet',
                      height: 6.0,
                      width: 70.0,
                      fit: BoxFit.none,
                    ),
                  );
                }),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.061,
                width: widget.constraints.maxWidth * 0.871,
                top: 194.0,
                height: 47.0,
                child: LayoutBuilder(builder: (context, constraints) {
                  return CryptoMarketOverview(
                    constraints,
                    ovrCoinCurrency: 'DASH/EUR',
                    ovrCurencyValue: '0.0834  EUR',
                    ovrPercentChange: '1.93%',
                    ovrMarketTrendline: SvgPicture.asset(
                      'assets/images/markettrendline.svg',
                      package: 'genius_wallet',
                      height: 6.0,
                      width: 70.0,
                      fit: BoxFit.none,
                    ),
                  );
                }),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.061,
                width: widget.constraints.maxWidth * 0.871,
                top: 259.0,
                height: 47.0,
                child: LayoutBuilder(builder: (context, constraints) {
                  return CryptoMarketOverview(
                    constraints,
                    ovrCoinCurrency: 'DASH/EUR',
                    ovrCurencyValue: '0.0834  EUR',
                    ovrPercentChange: '1.93%',
                    ovrMarketTrendline: SvgPicture.asset(
                      'assets/images/markettrendline.svg',
                      package: 'genius_wallet',
                      height: 6.0,
                      width: 70.0,
                      fit: BoxFit.none,
                    ),
                  );
                }),
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
