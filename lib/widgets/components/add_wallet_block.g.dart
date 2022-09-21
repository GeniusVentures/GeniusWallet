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
                width: 311.0,
                top: 0,
                height: 297.0,
                child: Container(
                  height: 297.0,
                  width: 311.0,
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
                width: 311.0,
                top: 0,
                height: 297.0,
                child: Container(
                  height: 297.0,
                  width: 311.0,
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
                left: 122.0,
                width: 68.0,
                top: 98.0,
                height: 99.0,
                child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(),
                    child: Stack(children: [
                      Positioned(
                        left: 0,
                        width: 69.0,
                        top: 82.0,
                        height: 16.0,
                        child: Container(
                            height: 16.0,
                            width: 69.0,
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
                            )),
                      ),
                      Positioned(
                        left: 9.0,
                        width: 50.0,
                        top: 0,
                        height: 50.0,
                        child: widget.ovrCombinedShape ??
                            Image.asset(
                              'assets/images/combinedshape.png',
                              package: 'genius_wallet',
                              height: 50.0,
                              width: 50.0,
                              fit: BoxFit.none,
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
