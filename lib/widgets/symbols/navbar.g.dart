import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Navbar extends StatelessWidget {
  final constraints;
  final ovrEllipseXor;
  final ovrShield;
  final ovrsettings;
  final ovrDex;
  final ovrWallet;
  Navbar(
    this.constraints, {
    Key key,
    this.ovrEllipseXor,
    this.ovrShield,
    this.ovrsettings,
    this.ovrDex,
    this.ovrWallet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: 0,
        width: constraints.maxWidth * 1.0,
        top: 0,
        height: constraints.maxHeight * 1.0,
        child: Container(
          width: constraints.maxWidth * 375.000,
          height: constraints.maxHeight * 77.000,
          decoration: BoxDecoration(
            color: Color(0xff0050c4),
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.123,
        width: constraints.maxWidth * 0.061,
        top: constraints.maxHeight * 0.123,
        height: constraints.maxHeight * 0.37,
        child: Image.asset(
          ovrShield ?? 'assets/images/0_12369.png',
          width: constraints.maxWidth * 22.871,
          height: constraints.maxHeight * 28.500,
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.102,
        width: constraints.maxWidth * 0.104,
        top: constraints.maxHeight * 0.494,
        height: constraints.maxHeight * 0.195,
        child: Container(
            width: constraints.maxWidth * 39.000,
            height: constraints.maxHeight * 15.000,
            child: AutoSizeText(
              ovrWallet ?? 'Wallet',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 10.0,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
      Positioned(
        left: constraints.maxWidth * 0.467,
        width: constraints.maxWidth * 0.067,
        top: constraints.maxHeight * 0.156,
        height: constraints.maxHeight * 0.247,
        child: Image.asset(
          'assets/images/110_3878.png',
          width: constraints.maxWidth * 25.000,
          height: constraints.maxHeight * 19.000,
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.472,
        width: constraints.maxWidth * 0.053,
        top: constraints.maxHeight * 0.494,
        height: constraints.maxHeight * 0.195,
        child: Container(
            width: constraints.maxWidth * 20.000,
            height: constraints.maxHeight * 15.000,
            child: AutoSizeText(
              ovrDex ?? 'Dex',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 10.0,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
      Positioned(
        left: constraints.maxWidth * 0.821,
        width: constraints.maxWidth * 0.06,
        top: constraints.maxHeight * 0.153,
        height: constraints.maxHeight * 0.292,
        child: Image.asset(
          ovrEllipseXor ?? 'assets/images/0_12375.png',
          width: constraints.maxWidth * 22.518,
          height: constraints.maxHeight * 22.518,
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.789,
        width: constraints.maxWidth * 0.123,
        top: constraints.maxHeight * 0.494,
        height: constraints.maxHeight * 0.195,
        child: Container(
            width: constraints.maxWidth * 46.000,
            height: constraints.maxHeight * 15.000,
            child: AutoSizeText(
              ovrsettings ?? 'settings',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 10.0,
                fontWeight: FontWeight.w300,
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
