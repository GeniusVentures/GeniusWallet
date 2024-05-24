import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/custom/currency_dropdown_to_custom.dart';

class ModeTo extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrTitle;
  final String? ovrcurrency;
  final Widget? ovrMaskCurrencySelector;
  const ModeTo(
    this.constraints, {
    Key? key,
    this.ovrTitle,
    this.ovrcurrency,
    this.ovrMaskCurrencySelector,
  }) : super(key: key);
  @override
  _ModeTo createState() => _ModeTo();
}

class _ModeTo extends State<ModeTo> {
  _ModeTo();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: Stack(children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                    child: AutoSizeText(
                  widget.ovrTitle ?? 'To',
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
                child: CurrencyDropdownToCustom(
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
          ),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
