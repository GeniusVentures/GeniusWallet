import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
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
                width: 68.0,
                top: 0,
                child: Container(
                    width: 68.0,
                    child: AutoSizeText(
                      widget.ovrTitle ?? 'To',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                        color: Color(0xff3a3c43),
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 0,
                top: 30,
                height: 35.0,
                child: CurrencyDropdownToCustom(
                    child: Container(
                        decoration: BoxDecoration(),
                        child: Stack(children: [
                          Positioned(
                            left: 181.0,
                            width: 7.0,
                            top: 11.0,
                            height: 14.0,
                            child: widget.ovrMaskCurrencySelector ??
                                Image.asset(
                                  'assets/images/maskcurrencyselector.png',
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
