// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/currency_dropdown_custom.dart';

class CurrencySelector extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrTitle;
  final String? ovrBitcoinBTC;
  final Widget? ovrMask;
  const CurrencySelector(
    this.constraints, {
    Key? key,
    this.ovrTitle,
    this.ovrBitcoinBTC,
    this.ovrMask,
  }) : super(key: key);
  @override
  _CurrencySelector createState() => _CurrencySelector();
}

class _CurrencySelector extends State<CurrencySelector> {
  _CurrencySelector();

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
                width: 34.0,
                top: 0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 34.0,
                    child: AutoSizeText(
                      widget.ovrTitle ?? 'FROM',
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
                left: 0,
                width: 311.0,
                top: 43.0,
                height: 35.0,
                child: CurrencyDropdownCustom(
                    child: Container(
                        decoration: BoxDecoration(),
                        child: Stack(children: [
                          Positioned(
                            left: 181.0,
                            width: 7.0,
                            top: 11.0,
                            height: 14.0,
                            child: widget.ovrMask ??
                                Image.asset(
                                  'assets/images/mask.png',
                                  package: 'genius_wallet',
                                  height: 14.0,
                                  width: 7.0,
                                  fit: BoxFit.none,
                                ),
                          ),
                          Positioned(
                            left: 0,
                            width: 188.0,
                            top: 0,
                            height: 35.0,
                            child: Container(
                                decoration: BoxDecoration(),
                                child: Stack(children: [
                                  Positioned(
                                    left: 0,
                                    width: 178.0,
                                    top: 0,
                                    height: 35.0,
                                    child: Container(
                                        height: 35.0,
                                        width: 178.0,
                                        child: AutoSizeText(
                                          widget.ovrBitcoinBTC ??
                                              'Bitcoin (BTC)',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 30.0,
                                            fontWeight: FontWeight.w300,
                                            letterSpacing: 0.45000001788139343,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.left,
                                        )),
                                  ),
                                ])),
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
