// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/coin_toggle_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';

class WalletToggle extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrWalletName;
  final Widget? ovrArrowToggle;
  final Widget? ovrShape;
  final String? ovrCoinName;
  const WalletToggle(
    this.constraints, {
    Key? key,
    this.ovrWalletName,
    this.ovrArrowToggle,
    this.ovrShape,
    this.ovrCoinName,
  }) : super(key: key);
  @override
  _WalletToggle createState() => _WalletToggle();
}

class _WalletToggle extends State<WalletToggle> {
  _WalletToggle();

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
                right: 0,
                width: 191.0,
                top: 0,
                height: 35.0,
                child: CoinToggleCustom(
                    child: Container(
                        decoration: BoxDecoration(),
                        child: Stack(children: [
                          Positioned(
                            right: 16.0,
                            width: 35.0,
                            top: 0,
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
                                        color: Color(0xfff2921b),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(2.0)),
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
                                    left: 8.922,
                                    width: 16.484,
                                    top: 7.656,
                                    height: 21.82,
                                    child: widget.ovrShape ??
                                        Image.asset(
                                          'assets/images/shape.png',
                                          package: 'genius_wallet',
                                          height: 21.820068359375,
                                          width: 16.484375,
                                          fit: BoxFit.none,
                                        ),
                                  ),
                                ])),
                          ),
                          Positioned(
                            right: 0,
                            width: 8.0,
                            top: 12.0,
                            height: 5.0,
                            child: widget.ovrArrowToggle ??
                                const Icon(Icons.arrow_drop_down, size: 14),
                          ),
                          Positioned(
                            right: 60.0,
                            width: 120.0,
                            top: 10.0,
                            height: 16.0,
                            child: SizedBox(
                                height: 16.0,
                                width: 120.0,
                                child: AutoSizeText(
                                  widget.ovrWalletName ?? 'My Bitcoin Wallet',
                                  style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.32307693362236023,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                )),
                          ),
                        ]))),
              ),
              Positioned(
                left: 0,
                width: 110.0,
                top: 7.0,
                height: 28.0,
                child: SizedBox(
                    height: 28.0,
                    width: 110.0,
                    child: AutoSizeText(
                      widget.ovrCoinName ?? 'Bitcoin',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
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
