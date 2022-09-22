// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
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
        decoration: BoxDecoration(),
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
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                    border: Border.all(
                      color: Color(0xff2a2b31),
                      width: 2.0,
                    ),
                  ),
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
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                    border: Border.all(
                      color: Color(0xff2a2b31),
                      width: 2.0,
                    ),
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
                        height: widget.constraints.maxHeight * 0.054,
                        child: Center(
                            child: Container(
                                height: 16.0,
                                width: widget.constraints.maxWidth *
                                    0.22186495176848875,
                                child: AutoSizeText(
                                  widget.ovrAddwallet ?? 'Add wallet',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.32307693362236023,
                                    color: Color(0xff2a2b31),
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
                              width: widget.constraints.maxWidth *
                                  0.1607717041800643,
                              fit: BoxFit.fill,
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
