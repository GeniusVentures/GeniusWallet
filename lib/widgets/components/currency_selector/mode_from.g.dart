import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/custom/currency_dropdown_from_custom.dart';

class ModeFrom extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrTitle;
  final String? ovrcurrency;
  final Widget? ovrMaskCurrencySelector;
  const ModeFrom(
    this.constraints, {
    Key? key,
    this.ovrTitle,
    this.ovrcurrency,
    this.ovrMaskCurrencySelector,
  }) : super(key: key);
  @override
  _ModeFrom createState() => _ModeFrom();
}

class _ModeFrom extends State<ModeFrom> {
  _ModeFrom();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: Stack(children: [
          Stack(children: [
            Positioned(
              left: 0,
              width: 68.0,
              top: 0,
              child: Container(
                  width: 68.0,
                  child: AutoSizeText(
                    widget.ovrTitle ?? 'From',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                      color: GeniusWalletColors.gray500,
                    ),
                    textAlign: TextAlign.left,
                  )),
            ),
            Positioned(
              left: 0,
              top: 30,
              child: CurrencyDropdownFromCustom(
                  child: Container(
                      decoration: BoxDecoration(),
                      child: Stack(children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                              decoration: BoxDecoration(),
                              child: Stack(children: [
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  child: Container(
                                      child: AutoSizeText(
                                    widget.ovrcurrency ?? 'Bitcoin (BTC)',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.3,
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
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
