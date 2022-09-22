// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';

class WalletQRCode extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrWalletID;
  const WalletQRCode(
    this.constraints, {
    Key? key,
    this.ovrWalletID,
  }) : super(key: key);
  @override
  _WalletQRCode createState() => _WalletQRCode();
}

class _WalletQRCode extends State<WalletQRCode> {
  _WalletQRCode();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: Stack(children: [
              Positioned(
                left: 0,
                width: 297.0,
                top: 0,
                height: 233.0,
                child: Container(
                  height: 233.0,
                  width: 297.0,
                  decoration: BoxDecoration(
                    color: Color(0xff2a2b31),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                ),
              ),
              Positioned(
                left: 81.0,
                width: 101.25,
                top: 23.0,
                height: 101.25,
                child: SvgPicture.asset(
                  'assets/images/walletqrcode.svg',
                  package: 'genius_wallet',
                  height: 101.25,
                  width: 101.25,
                  fit: BoxFit.none,
                ),
              ),
              Positioned(
                left: 2.0,
                width: 291.0,
                top: 169.0,
                height: 16.0,
                child: Container(
                    height: 16.0,
                    width: 291.0,
                    child: AutoSizeText(
                      widget.ovrWalletID ??
                          '3HP94BwsdMHifjdsfJksdndaJhd oopskd',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
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
