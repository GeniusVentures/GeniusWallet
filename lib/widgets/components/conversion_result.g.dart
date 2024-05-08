import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

class ConversionResult extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrResult;
  final String? ovrAmountentered;
  const ConversionResult(
    this.constraints, {
    Key? key,
    this.ovrResult,
    this.ovrAmountentered,
  }) : super(key: key);
  @override
  _ConversionResult createState() => _ConversionResult();
}

class _ConversionResult extends State<ConversionResult> {
  _ConversionResult();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth,
            top: 0,
            height: widget.constraints.maxHeight,
            child: Stack(children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  height: widget.constraints.maxHeight,
                  width: widget.constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: GeniusWalletColors.containerGray,
                    borderRadius: BorderRadius.all(
                        Radius.circular(GeniusWalletConsts.borderRadiusCard)),
                  ),
                ),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.075,
                width: widget.constraints.maxWidth * 0.846,
                top: widget.constraints.maxHeight * 0.6,
                height: widget.constraints.maxHeight * 0.341,
                child: Center(
                    child: Container(
                        height: 45.0,
                        child: AutoSizeText(
                          widget.ovrResult ?? 'BTC = 3748.76 USD',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ))),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.075,
                width: widget.constraints.maxWidth * 0.846,
                top: widget.constraints.maxHeight * 0.189,
                height: widget.constraints.maxHeight * 0.303,
                child: Center(
                    child: Container(
                        height: 40.0,
                        child: AutoSizeText(
                          widget.ovrAmountentered ?? '0.3333333333',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 36.0,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.3,
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
