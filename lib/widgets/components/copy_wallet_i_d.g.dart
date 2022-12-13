// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/copy_wallet_i_d_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CopyWalletID extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrCopyWalletLabel;
  final Widget? ovrCopyIcon;
  const CopyWalletID(
    this.constraints, {
    Key? key,
    this.ovrCopyWalletLabel,
    this.ovrCopyIcon,
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
              Positioned(
                left: 0,
                width: 13.5,
                top: 1.0,
                height: 16.0,
                child: widget.ovrCopyIcon ??
                    SvgPicture.asset(
                      'assets/images/copyicon.svg',
                      package: 'genius_wallet',
                      height: 16.0,
                      width: 13.5,
                      fit: BoxFit.none,
                    ),
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
