import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CoverSendCryptoDesktop extends StatelessWidget {
  final constraints;
  final ovrRecipientAddress;
  final ovrPaste;
  final ovrETHAmount;
  final ovrMaxETH;
  final ovrSendeth;
  CoverSendCryptoDesktop(
    this.constraints, {
    Key key,
    this.ovrRecipientAddress,
    this.ovrPaste,
    this.ovrETHAmount,
    this.ovrMaxETH,
    this.ovrSendeth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: 0,
        width: constraints.maxWidth * 0.824,
        top: constraints.maxHeight * 0.373,
        height: constraints.maxHeight * 0.39,
        child: Image.asset(
          'assets/images/0_12700.png',
          width: constraints.maxWidth * 351.000,
          height: constraints.maxHeight * 131.000,
        ),
      ),
      Positioned(
        left: 0,
        width: constraints.maxWidth * 0.824,
        top: constraints.maxHeight * 0.373,
        height: constraints.maxHeight * 0.313,
        child: Container(
          width: constraints.maxWidth * 351.000,
          height: constraints.maxHeight * 105.100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: 17.026,
        right: 14.0,
        top: constraints.maxHeight * 0.605,
        height: constraints.maxHeight * 0.08,
        child: Center(
            child: Container(
                height: 27.0,
                child: Stack(children: [
                  Positioned(
                    left: 0,
                    width: constraints.maxWidth * 0.714,
                    top: 0,
                    height: 27.0,
                    child: Container(
                      width: constraints.maxWidth * 304.000,
                      height: constraints.maxHeight * 27.000,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(0)),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    width: 116.0,
                    top: 3.0,
                    height: 21.0,
                    child: Container(
                        width: constraints.maxWidth * 116.000,
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
                    left: 0,
                    width: 188.0,
                    top: 0,
                    height: 27.0,
                    child: Container(
                        width: constraints.maxWidth * 188.000,
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
                ]))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.07,
        width: constraints.maxWidth * 0.686,
        top: 0,
        height: constraints.maxHeight * 0.096,
        child: Container(
            width: constraints.maxWidth * 292.309,
            height: constraints.maxHeight * 32.400,
            child: AutoSizeText(
              ovrSendeth ?? 'Send eth',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 36.0,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
      Positioned(
        left: 17.026,
        right: 17.826,
        top: constraints.maxHeight * 0.415,
        height: constraints.maxHeight * 0.089,
        child: Center(
            child: Container(
                height: 29.797561645507812,
                child: Stack(children: [
                  Positioned(
                    left: 0,
                    width: constraints.maxWidth * 0.742,
                    top: 0,
                    height: 27.0,
                    child: Container(
                      width: constraints.maxWidth * 316.000,
                      height: constraints.maxHeight * 27.000,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(0)),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 36.174,
                    width: 68.0,
                    top: 3.0,
                    height: 21.0,
                    child: Container(
                        width: constraints.maxWidth * 68.000,
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
                    left: 0,
                    width: 219.0,
                    top: 0,
                    height: 27.0,
                    child: Container(
                        width: constraints.maxWidth * 219.000,
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
                    left: 291.168,
                    width: 25.006,
                    top: 4.761,
                    height: 25.036,
                    child: Image.asset(
                      'assets/images/0_12707.png',
                      width: constraints.maxWidth * 25.006,
                      height: constraints.maxHeight * 25.036,
                    ),
                  ),
                ]))),
      ),
    ]);
  }
}
