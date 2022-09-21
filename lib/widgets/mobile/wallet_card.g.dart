// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/mobile/white_arrow/pointing_right.g.dart';
import 'package:genius_wallet/widgets/mobile/custom/wallet_card_custom.dart';
import 'package:genius_wallet/widgets/mobile/custom/white_arrow_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';

class WalletCard extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrEthereum;
  final Widget? ovrEllipse1;
  const WalletCard(
    this.constraints, {
    Key? key,
    this.ovrEthereum,
    this.ovrEllipse1,
  }) : super(key: key);
  @override
  _WalletCard createState() => _WalletCard();
}

class _WalletCard extends State<WalletCard> {
  _WalletCard();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: WalletCardCustom(
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
                height: 55.0,
                child: Container(
                  height: 55.0,
                  width: 311.0,
                  decoration: BoxDecoration(
                    color: Color(0xff2a2b31),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
              Positioned(
                left: 287.0,
                width: 5.0,
                top: 24.0,
                height: 9.0,
                child: WhiteArrowCustom(
                    child: LayoutBuilder(builder: (context, constraints) {
                  return PointingRight(
                    constraints,
                    ovrWhiteArrowRight: SvgPicture.asset(
                      'assets/images/whitearrowright.svg',
                      package: 'genius_wallet',
                      height: 9.0,
                      width: 5.0,
                      fit: BoxFit.none,
                    ),
                  );
                })),
              ),
              Positioned(
                left: 62.0,
                width: 61.0,
                top: 20.0,
                height: 16.0,
                child: Container(
                    height: 16.0,
                    width: 61.0,
                    child: AutoSizeText(
                      widget.ovrEthereum ?? 'Ethereum',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.13750000298023224,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 12.0,
                width: 30.0,
                top: 13.0,
                height: 30.0,
                child: widget.ovrEllipse1 ??
                    Image.asset(
                      'assets/images/ellipse1.png',
                      package: 'genius_wallet',
                      height: 30.0,
                      width: 30.0,
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
