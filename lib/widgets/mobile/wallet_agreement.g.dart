// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/mobile/custom/wallet_agreement_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class WalletAgreement extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrIvereadandaccepttheTermsofServiceandPrivacyPolicy;
  const WalletAgreement(
    this.constraints, {
    Key? key,
    this.ovrIvereadandaccepttheTermsofServiceandPrivacyPolicy,
  }) : super(key: key);
  @override
  _WalletAgreement createState() => _WalletAgreement();
}

class _WalletAgreement extends State<WalletAgreement> {
  _WalletAgreement();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: WalletAgreementCustom(
            child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: Stack(children: [
              Positioned(
                left: 29.0,
                right: 2.0,
                top: 0,
                height: 34.0,
                child: Container(
                    height: 34.0,
                    width: widget.constraints.maxWidth * 0.9051987767584098,
                    child: AutoSizeText(
                      widget.ovrIvereadandaccepttheTermsofServiceandPrivacyPolicy ??
                          'I’ve read and accept the Terms of Service and Privacy Policy',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 0,
                width: 14.0,
                top: 2.0,
                height: 14.0,
                child: Container(
                  height: 14.0,
                  width: 14.0,
                  decoration: BoxDecoration(
                    color: Color(0xff18191d),
                    borderRadius: BorderRadius.all(Radius.circular(1.0)),
                    border: Border.all(
                      color: Color(0xff0068ef),
                      width: 1.0,
                    ),
                  ),
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
