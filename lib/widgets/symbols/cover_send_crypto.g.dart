import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/controller/tag/paste_custom.dart';
import 'package:geniuswallet/controller/tag/max_e_t_h_custom.dart';
import 'package:geniuswallet/controller/tag/e_t_h_amount_custom.dart';
import 'package:geniuswallet/controller/tag/recipient_address_custom.dart';
import 'package:geniuswallet/controller/tag/scan_custom.dart';

class CoverSendCrypto extends StatelessWidget {
  final constraints;
  final ovrSendeth;
  CoverSendCrypto(
    this.constraints, {
    Key key,
    this.ovrSendeth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: 0,
        width: constraints.maxWidth * 1.003,
        top: 0,
        height: 229.0,
        child: Container(
          width: constraints.maxWidth * 377.003,
          height: constraints.maxHeight * 229.000,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.003,
        width: constraints.maxWidth * 1.0,
        top: 0,
        height: 229.0,
        child: Container(
          width: constraints.maxWidth * 376.000,
          height: constraints.maxHeight * 229.000,
          decoration: BoxDecoration(
            color: Color(0xff0050c4),
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: 0,
        width: 377.003,
        top: 0,
        height: 229.0,
        child: Image.asset(
          'assets/images/0_12212.png',
          width: constraints.maxWidth * 377.003,
          height: constraints.maxHeight * 229.000,
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.159,
        width: constraints.maxWidth * 0.686,
        top: 15.429,
        height: 22.468,
        child: Container(
            width: constraints.maxWidth * 258.000,
            height: constraints.maxHeight * 22.468,
            child: AutoSizeText(
              ovrSendeth ?? 'Send eth',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
      Positioned(
        left: 37.601,
        right: 38.401,
        top: 96.45,
        height: 105.1,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.801,
            top: 0,
            height: 105.1,
            child: Container(
              width: constraints.maxWidth * 301.000,
              height: constraints.maxHeight * 105.100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            width: constraints.maxWidth * 0.801,
            top: 0,
            height: 105.1,
            child: Image.asset(
              'assets/images/0_12219.png',
              width: constraints.maxWidth * 301.000,
              height: constraints.maxHeight * 105.100,
            ),
          ),
          Positioned(
            right: 52.0,
            width: 48.0,
            top: 17.0,
            height: 21.0,
            child: PasteCustom(
                child: AutoSizeText(
              'Paste',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Color(0xff003698),
              ),
              textAlign: TextAlign.right,
            )),
          ),
          Positioned(
            right: 30.0,
            width: 83.0,
            top: 68.0,
            height: 21.0,
            child: MaxETHCustom(
                child: AutoSizeText(
              'Max ETH',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Color(0xff003698),
              ),
              textAlign: TextAlign.right,
            )),
          ),
          Positioned(
            left: 17.0,
            width: 133.0,
            top: 65.0,
            height: 27.0,
            child: ETHAmountCustom(
                child: AutoSizeText(
              'ETH Amount',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Color(0xff575757),
              ),
              textAlign: TextAlign.left,
            )),
          ),
          Positioned(
            left: 17.0,
            width: 171.0,
            top: 14.0,
            height: 27.0,
            child: RecipientAddressCustom(
                child: AutoSizeText(
              'Recipient Address',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Color(0xff575757),
              ),
              textAlign: TextAlign.left,
            )),
          ),
          Positioned(
            right: 17.5,
            width: 19.0,
            top: 18.5,
            height: 17.0,
            child: ScanCustom(
                child: Image.asset(
              'assets/images/167_1946.png',
              width: constraints.maxWidth * 19.000,
              height: constraints.maxHeight * 17.000,
            )),
          ),
        ]),
      ),
    ]);
  }
}
