import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CryptoItemDesktop extends StatelessWidget {
  final constraints;
  final ovrLine;
  final ovrEllipse;
  final ovr2099;
  final ovr0BTC;
  final ovr418;
  final ovr4630950;
  final ovrCrypto;
  CryptoItemDesktop(
    this.constraints, {
    Key key,
    this.ovrLine,
    this.ovrEllipse,
    this.ovr2099,
    this.ovr0BTC,
    this.ovr418,
    this.ovr4630950,
    this.ovrCrypto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: 0,
        width: constraints.maxWidth * 1.0,
        top: 0,
        height: constraints.maxHeight * 0.027,
        child: ovrLine ??
            Image.asset(
              'assets/images/200_3395.png',
              width: constraints.maxWidth * 385.000,
              height: constraints.maxHeight * 3.405,
            ),
      ),
      Positioned(
        left: 0,
        width: 75.0,
        top: constraints.maxHeight * 0.405,
        height: constraints.maxHeight * 0.595,
        child: ovrEllipse ??
            Image.asset(
              'assets/images/200_3396.png',
              width: constraints.maxWidth * 75.000,
              height: constraints.maxHeight * 75.000,
            ),
      ),
      Positioned(
        right: 0,
        width: 110.321,
        top: constraints.maxHeight * 0.563,
        height: constraints.maxHeight * 0.258,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: 110.321,
            top: 0,
            height: constraints.maxHeight * 0.254,
            child: Container(
              width: constraints.maxWidth * 110.321,
              height: constraints.maxHeight * 32.000,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            width: 110.321,
            top: 0,
            height: constraints.maxHeight * 0.095,
            child: Container(
                width: constraints.maxWidth * 110.321,
                height: constraints.maxHeight * 12.000,
                child: AutoSizeText(
                  ovr0BTC ?? '0 BTC',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    letterSpacing: 0.0,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                )),
          ),
          Positioned(
            left: 34.321,
            width: 76.0,
            top: constraints.maxHeight * 0.163,
            height: constraints.maxHeight * 0.095,
            child: Container(
                width: constraints.maxWidth * 76.000,
                height: constraints.maxHeight * 12.000,
                child: AutoSizeText(
                  ovr2099 ?? '\$20.99',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.normal,
                    letterSpacing: 0.0,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                )),
          ),
        ]),
      ),
      Positioned(
        left: 105.0,
        width: 188.0,
        top: constraints.maxHeight * 0.579,
        height: constraints.maxHeight * 0.262,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: 188.0,
            top: 0,
            height: constraints.maxHeight * 0.254,
            child: Container(
              width: constraints.maxWidth * 188.000,
              height: constraints.maxHeight * 32.000,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            width: 188.0,
            top: 0,
            height: constraints.maxHeight * 0.095,
            child: Container(
                width: constraints.maxWidth * 188.000,
                height: constraints.maxHeight * 12.000,
                child: AutoSizeText(
                  ovrCrypto ?? 'Crypto',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 24.0,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    letterSpacing: 0.0,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.left,
                )),
          ),
          Positioned(
            left: 0,
            width: 119.155,
            top: constraints.maxHeight * 0.167,
            height: constraints.maxHeight * 0.095,
            child: Container(
                width: constraints.maxWidth * 119.155,
                height: constraints.maxHeight * 12.000,
                child: AutoSizeText(
                  ovr4630950 ?? '\$46,309.50',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.normal,
                    letterSpacing: 0.0,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.left,
                )),
          ),
          Positioned(
            left: 119.155,
            width: 68.845,
            top: constraints.maxHeight * 0.167,
            height: constraints.maxHeight * 0.095,
            child: Container(
                width: constraints.maxWidth * 68.845,
                height: constraints.maxHeight * 12.000,
                child: AutoSizeText(
                  ovr418 ?? '+4.18%',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.normal,
                    letterSpacing: 0.0,
                    color: Color(0xff00f1ac),
                  ),
                  textAlign: TextAlign.left,
                )),
          ),
        ]),
      ),
    ]);
  }
}
