// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';
import 'package:genius_wallet/widgets/components/custom/add_wallet_block_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class AddWalletBlock extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrCombinedShape;
  final String? ovrAddwallet;
  const AddWalletBlock(
    this.constraints, {
    Key? key,
    this.ovrCombinedShape,
    this.ovrAddwallet,
  }) : super(key: key);
  @override
  _AddWalletBlock createState() => _AddWalletBlock();
}

class _AddWalletBlock extends State<AddWalletBlock> {
  _AddWalletBlock();

  @override
  Widget build(BuildContext context) {
    return Container(
        child: AddWalletBlockCustom(
            child: Stack(children: [
      Positioned(
        left: 0,
        width: widget.constraints.maxWidth * 1.0,
        top: 0,
        height: widget.constraints.maxHeight * 1.0,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: Container(
              height: widget.constraints.maxHeight * 1.0,
              width: widget.constraints.maxWidth * 1.0,
            ),
          ),
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: Container(
              height: widget.constraints.maxHeight * 1.0,
              width: widget.constraints.maxWidth * 1.0,
              decoration: const BoxDecoration(
                color: GeniusWalletColors.deepBlueCardColor,
                borderRadius: BorderRadius.all(
                    Radius.circular(GeniusWalletConsts.borderRadiusCard)),
              ),
            ),
          ),
          Positioned(
            left: widget.constraints.maxWidth * 0.392,
            width: widget.constraints.maxWidth * 0.219,
            top: widget.constraints.maxHeight * 0.33,
            height: widget.constraints.maxHeight * 0.333,
            child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(),
                child: Stack(children: [
                  Positioned(
                    left: 0,
                    width: widget.constraints.maxWidth * 0.222,
                    top: widget.constraints.maxHeight * 0.276,
                    height: widget.constraints.maxHeight * 0.07,
                    child: Center(
                        child: SizedBox(
                            height: GeniusWalletFontSize.sectionHeader,
                            width: widget.constraints.maxWidth *
                                0.22186495176848875,
                            child: AutoSizeText(
                              widget.ovrAddwallet ?? 'Add wallet',
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: GeniusWalletFontSize.sectionHeader,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.32307693362236023,
                                color: GeniusWalletColors.lightGreenPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ))),
                  ),
                  Positioned(
                    left: widget.constraints.maxWidth * 0.029,
                    width: widget.constraints.maxWidth * 0.161,
                    top: 0,
                    height: widget.constraints.maxHeight * 0.168,
                    child: widget.ovrCombinedShape ??
                        Image.asset(
                          'assets/images/combinedshape.png',
                          package: 'genius_wallet',
                          height: widget.constraints.maxHeight *
                              0.16835016835016836,
                          width:
                              widget.constraints.maxWidth * 0.1607717041800643,
                          fit: BoxFit.fill,
                          color: Colors.white,
                        ),
                  ),
                ])),
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
