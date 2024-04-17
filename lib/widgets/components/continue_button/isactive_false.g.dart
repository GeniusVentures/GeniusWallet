// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_text.dart';
import 'package:genius_wallet/widgets/components/custom/isactive_false_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class IsactiveFalse extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrContinue;
  const IsactiveFalse(
    this.constraints, {
    Key? key,
    this.ovrContinue,
  }) : super(key: key);
  @override
  _IsactiveFalse createState() => _IsactiveFalse();
}

class _IsactiveFalse extends State<IsactiveFalse> {
  _IsactiveFalse();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(),
        child: IsactiveFalseCustom(
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
                bottom: 0,
                child: Container(
                  height: widget.constraints.maxHeight * 1.0,
                  width: widget.constraints.maxWidth * 1.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(48),
                    color: GeniusWalletColors.btnDisabled,
                  ),
                ),
              ),
              Positioned(
                left: 113.0,
                right: 114.0,
                top: 16.0,
                bottom: 17.0,
                child: Container(
                    height: widget.constraints.maxHeight * 0.2826086956521739,
                    width: widget.constraints.maxWidth * 0.27936507936507937,
                    child: AutoSizeText(
                      widget.ovrContinue ?? GeniusWalletText.btnContinue,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.13750000298023224,
                        color: GeniusWalletColors.btnTextDisabled,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
            ]),
          ),
        ])));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
