import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class NavbarDesktop extends StatelessWidget {
  final constraints;
  final ovrTriangle;
  final ovrAvatar;
  final ovrWallet;
  final ovrShield;
  final ovrDex2;
  final ovrsettings;
  final ovrEllipseXor;
  NavbarDesktop(
    this.constraints, {
    Key key,
    this.ovrTriangle,
    this.ovrAvatar,
    this.ovrWallet,
    this.ovrShield,
    this.ovrDex2,
    this.ovrsettings,
    this.ovrEllipseXor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: 4.0,
        width: 1920.0,
        top: 0,
        height: 67.0,
        child: Image.asset(
          'assets/images/0_12542.png',
          width: constraints.maxWidth * 1920.000,
          height: constraints.maxHeight * 67.000,
        ),
      ),
      Positioned(
        left: 24.5,
        width: 44.0,
        top: 17.5,
        height: 2.0,
        child: Image.asset(
          'assets/images/0_12552.png',
          width: constraints.maxWidth * 44.000,
          height: constraints.maxHeight * 2.000,
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.748,
        width: constraints.maxWidth * 0.012,
        top: constraints.maxHeight * 0.284,
        height: constraints.maxHeight * 0.425,
        child: Image.asset(
          ovrShield ?? 'assets/images/0_12560.png',
          width: constraints.maxWidth * 22.871,
          height: constraints.maxHeight * 28.500,
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.879,
        width: constraints.maxWidth * 0.013,
        top: constraints.maxHeight * 0.305,
        height: constraints.maxHeight * 0.361,
        child: Image.asset(
          ovrEllipseXor ?? 'assets/images/0_12570.png',
          width: constraints.maxWidth * 24.168,
          height: constraints.maxHeight * 24.169,
        ),
      ),
      Positioned(
        left: 1575.4,
        width: 25.0,
        top: 26.5,
        height: 2.0,
        child: Image.asset(
          'assets/images/0_12563.png',
          width: constraints.maxWidth * 25.000,
          height: constraints.maxHeight * 2.000,
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.955,
        width: constraints.maxWidth * 0.026,
        top: constraints.maxHeight * 0.119,
        height: constraints.maxHeight * 0.746,
        child: Image.asset(
          ovrAvatar ?? 'assets/images/0_12550.png',
          width: constraints.maxWidth * 50.000,
          height: constraints.maxHeight * 50.000,
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.763,
        width: constraints.maxWidth * 0.036,
        top: constraints.maxHeight * 0.299,
        height: constraints.maxHeight * 0.403,
        child: Container(
            width: constraints.maxWidth * 70.000,
            height: constraints.maxHeight * 27.000,
            child: AutoSizeText(
              ovrWallet ?? 'Wallet',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 18.0,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
      Positioned(
        left: constraints.maxWidth * 0.84,
        width: constraints.maxWidth * 0.019,
        top: constraints.maxHeight * 0.299,
        height: constraints.maxHeight * 0.403,
        child: Container(
            width: constraints.maxWidth * 36.000,
            height: constraints.maxHeight * 27.000,
            child: AutoSizeText(
              ovrDex2 ?? 'Dex',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 18.0,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
      Positioned(
        left: constraints.maxWidth * 0.894,
        width: constraints.maxWidth * 0.043,
        top: constraints.maxHeight * 0.299,
        height: constraints.maxHeight * 0.403,
        child: Container(
            width: constraints.maxWidth * 82.000,
            height: constraints.maxHeight * 27.000,
            child: AutoSizeText(
              ovrsettings ?? 'settings',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 18.0,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
      Positioned(
        left: constraints.maxWidth * 0.983,
        width: constraints.maxWidth * 0.007,
        top: constraints.maxHeight * 0.731,
        height: constraints.maxHeight * 0.134,
        child: Image.asset(
          ovrTriangle ?? 'assets/images/0_12551.png',
          width: constraints.maxWidth * 13.000,
          height: constraints.maxHeight * 9.000,
        ),
      ),
      Positioned(
        left: 98.0,
        width: 50.0,
        top: 8.0,
        height: 50.0,
        child: Image.asset(
          'assets/images/0_12556.png',
          width: constraints.maxWidth * 50.000,
          height: constraints.maxHeight * 50.000,
        ),
      ),
    ]);
  }
}
