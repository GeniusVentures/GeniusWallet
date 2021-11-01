import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CryptoItem extends StatelessWidget {
  final constraints;
  final ovrLine;
  final ovrEllipse;
  final ovr2099;
  final ovr0BTC;
  final ovr418;
  final ovr4630950;
  final ovrCrypto;
  CryptoItem(
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
              'assets/images/0_12431.png',
              width: constraints.maxWidth * 281.000,
              height: constraints.maxHeight * 2.000,
            ),
      ),
      Positioned(
        left: 0,
        width: 36.774,
        top: constraints.maxHeight * 0.196,
        height: constraints.maxHeight * 0.497,
        child: ovrEllipse ??
            Image.asset(
              'assets/images/0_12432.png',
              width: constraints.maxWidth * 36.774,
              height: constraints.maxHeight * 36.770,
            ),
      ),
      Positioned(
        right: 0,
        width: 110.322,
        top: 22.5,
        height: 32.0,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: 110.322,
            top: 0,
            height: 32.0,
            child: Container(
              width: constraints.maxWidth * 110.322,
              height: constraints.maxHeight * 32.000,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            width: 110.322,
            top: 0,
            height: 12.0,
            child: Container(
                width: constraints.maxWidth * 110.322,
                height: constraints.maxHeight * 12.000,
                child: AutoSizeText(
                  ovr0BTC ?? '0 BTC',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    letterSpacing: 0.0,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                )),
          ),
          Positioned(
            left: 66.322,
            width: 44.0,
            top: 20.0,
            height: 12.0,
            child: Container(
                width: constraints.maxWidth * 44.000,
                height: constraints.maxHeight * 12.000,
                child: AutoSizeText(
                  ovr2099 ?? '\$20.99',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 11.0,
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
        left: 49.165,
        width: 118.316,
        top: 22.5,
        height: 32.0,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: 118.316,
            top: 0,
            height: 32.0,
            child: Container(
              width: constraints.maxWidth * 118.316,
              height: constraints.maxHeight * 32.000,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            width: 118.316,
            top: 0,
            height: 12.0,
            child: Container(
                width: constraints.maxWidth * 118.316,
                height: constraints.maxHeight * 12.000,
                child: AutoSizeText(
                  ovrCrypto ?? 'Crypto',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 14.0,
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
            width: 59.0,
            top: 20.0,
            height: 12.0,
            child: Container(
                width: constraints.maxWidth * 59.000,
                height: constraints.maxHeight * 12.000,
                child: AutoSizeText(
                  ovr4630950 ?? '\$46,309.50',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 11.0,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.normal,
                    letterSpacing: 0.0,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.left,
                )),
          ),
          Positioned(
            left: 66.164,
            width: 52.0,
            top: 20.0,
            height: 12.0,
            child: Container(
                width: constraints.maxWidth * 52.000,
                height: constraints.maxHeight * 12.000,
                child: AutoSizeText(
                  ovr418 ?? '+4.18%',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 11.0,
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
