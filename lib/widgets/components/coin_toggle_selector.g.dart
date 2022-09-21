// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/coin_toggle_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CoinToggleSelector extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrCoinCurrencyLabel;
  const CoinToggleSelector(
    this.constraints, {
    Key? key,
    this.ovrCoinCurrencyLabel,
  }) : super(key: key);
  @override
  _CoinToggleSelector createState() => _CoinToggleSelector();
}

class _CoinToggleSelector extends State<CoinToggleSelector> {
  _CoinToggleSelector();

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
                width: 109.0,
                top: 0,
                height: 35.0,
                child: Container(
                  height: 35.0,
                  width: 109.0,
                  decoration: BoxDecoration(
                    color: Color(0xff1d2024),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
              Positioned(
                left: 90.0,
                width: 7.0,
                top: 10.0,
                height: 14.0,
                child: CoinToggleCustom(
                    child: SvgPicture.asset(
                  'assets/images/cointogglecustom.svg',
                  package: 'genius_wallet',
                  height: 14.0,
                  width: 7.0,
                  fit: BoxFit.none,
                )),
              ),
              Positioned(
                left: 13.0,
                width: 61.0,
                top: 9.0,
                height: 16.0,
                child: Container(
                    height: 16.0,
                    width: 61.0,
                    child: AutoSizeText(
                      widget.ovrCoinCurrencyLabel ?? 'BTC/USD',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.32307693362236023,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
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
