// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

class DesktopConversionResult extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrAmountEntered;
  final String? ovrResult;
  final String? ovr;
  const DesktopConversionResult(
    this.constraints, {
    Key? key,
    this.ovrAmountEntered,
    this.ovrResult,
    this.ovr,
  }) : super(key: key);
  @override
  _DesktopConversionResult createState() => _DesktopConversionResult();
}

class _DesktopConversionResult extends State<DesktopConversionResult> {
  _DesktopConversionResult();

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
                width: 540,
                top: 0,
                height: 68.0,
                child: Container(
                  height: 68.0,
                  decoration: BoxDecoration(
                    color: GeniusWalletColors.gray900,
                    borderRadius: BorderRadius.all(
                        Radius.circular(GeniusWalletConsts.borderRadiusCard)),
                  ),
                ),
              ),
              Positioned(
                left: 18.0,
                width: 311.0,
                top: widget.constraints.maxHeight * 0.25,
                height: widget.constraints.maxHeight * 0.515,
                child: Center(
                    child: Container(
                        height: 35.0,
                        width: 311.0,
                        child: AutoSizeText(
                          widget.ovrAmountEntered ?? '0.3333333333333 BTC',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 30.0,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.45000001788139343,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ))),
              ),
              Positioned(
                right: 16.5,
                width: 177.0,
                top: widget.constraints.maxHeight * 0.25,
                height: widget.constraints.maxHeight * 0.515,
                child: Center(
                    child: Container(
                        height: 35.0,
                        width: 177.0,
                        child: AutoSizeText(
                          widget.ovrResult ?? '3748.76 USD',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 30.0,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.45000001788139343,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ))),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.605,
                width: widget.constraints.maxWidth * 0.03,
                top: widget.constraints.maxHeight * 0.25,
                height: widget.constraints.maxHeight * 0.515,
                child: Center(
                    child: Container(
                        height: 35.0,
                        width: 17.0,
                        child: AutoSizeText(
                          widget.ovr ?? '=',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 30.0,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.45000001788139343,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ))),
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
