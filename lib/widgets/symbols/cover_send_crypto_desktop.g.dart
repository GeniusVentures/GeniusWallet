import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CoverSendCryptoDesktop extends StatelessWidget {
  final constraints;
  final ovrPaste;
  final ovrMaxETH;
  final ovrETHAmount;
  final ovrRecipientAddress;
  final ovrSendeth;
  CoverSendCryptoDesktop(
    this.constraints, {
    Key key,
    this.ovrPaste,
    this.ovrMaxETH,
    this.ovrETHAmount,
    this.ovrRecipientAddress,
    this.ovrSendeth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: 0,
        right: 0,
        top: constraints.maxHeight * 0.348,
        height: constraints.maxHeight * 0.451,
        child: Image.asset(
          'assets/images/0_12700.png',
          width: constraints.maxWidth * 301.000,
          height: constraints.maxHeight * 105.100,
        ),
      ),
      Positioned(
        right: 52.0,
        width: 48.0,
        top: 98.021,
        height: 21.0,
        child: Container(
            width: constraints.maxWidth * 48.000,
            height: constraints.maxHeight * 21.000,
            child: AutoSizeText(
              ovrPaste ?? 'Paste',
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
        top: 149.021,
        height: 21.0,
        child: Container(
            width: constraints.maxWidth * 83.000,
            height: constraints.maxHeight * 21.000,
            child: AutoSizeText(
              ovrMaxETH ?? 'Max ETH',
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
        top: 146.021,
        height: 27.0,
        child: Container(
            width: constraints.maxWidth * 133.000,
            height: constraints.maxHeight * 27.000,
            child: AutoSizeText(
              ovrETHAmount ?? 'ETH Amount',
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
        top: 95.021,
        height: 27.0,
        child: Container(
            width: constraints.maxWidth * 171.000,
            height: constraints.maxHeight * 27.000,
            child: AutoSizeText(
              ovrRecipientAddress ?? 'Recipient Address',
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
        left: 265.0,
        width: 18.0,
        top: 100.021,
        height: 16.0,
        child: Image.asset(
          'assets/images/0_12707.png',
          width: constraints.maxWidth * 18.000,
          height: constraints.maxHeight * 16.000,
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.059,
        width: constraints.maxWidth * 0.686,
        top: 0,
        height: constraints.maxHeight * 0.096,
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
    ]);
  }
}
