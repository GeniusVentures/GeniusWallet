// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/custom/q_r_code_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WalletQRScan extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrQRScanPrompt;
  const WalletQRScan(
    this.constraints, {
    Key? key,
    this.ovrQRScanPrompt,
  }) : super(key: key);
  @override
  _WalletQRScan createState() => _WalletQRScan();
}

class _WalletQRScan extends State<WalletQRScan> {
  _WalletQRScan();

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
                height: 16.0,
                child: Container(
                    width: widget.constraints.maxWidth * 1.0,
                    child: AutoSizeText(
                      widget.ovrQRScanPrompt ?? 'Scan wallet instead ?',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.396,
                width: widget.constraints.maxWidth * 0.207,
                top: 27.0,
                height: 34.0,
                child: Center(
                    child: Container(
                        height: 34.0,
                        width: 34.0,
                        child: QRCodeCustom(
                            child: Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(),
                                child: Stack(children: [
                                  Positioned(
                                    left: 0,
                                    width: 34.0,
                                    top: 0,
                                    height: 34.0,
                                    child: SvgPicture.asset(
                                      'assets/images/group.svg',
                                      color:
                                          GeniusWalletColors.lightGreenPrimary,
                                      package: 'genius_wallet',
                                      height: 34.0,
                                      width: 34.0,
                                      fit: BoxFit.none,
                                    ),
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
