// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/copy_wallet_i_d_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CopyWalletID extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrCopyWalletLabel;
  const CopyWalletID(
    this.constraints, {
    Key? key,
    this.ovrCopyWalletLabel,
  }) : super(key: key);
  @override
  _CopyWalletID createState() => _CopyWalletID();
}

class _CopyWalletID extends State<CopyWalletID> {
  _CopyWalletID();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: CopyWalletIDCustom(
            child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: Stack(children: [
              Positioned(
                left: 0,
                width: 11.0,
                top: 1.0,
                height: 13.5,
                child: SvgPicture.asset(
                  'assets/images/copywalletsymbol.svg',
                  package: 'genius_wallet',
                  height: 13.5,
                  width: 11.0,
                  fit: BoxFit.none,
                ),
              ),
              Positioned(
                left: 20.0,
                width: 32.0,
                top: 0,
                height: 16.0,
                child: Container(
                    height: 16.0,
                    width: 32.0,
                    child: AutoSizeText(
                      widget.ovrCopyWalletLabel ?? 'Copy',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
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
