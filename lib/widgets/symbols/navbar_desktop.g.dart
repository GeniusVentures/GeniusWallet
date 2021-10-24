import 'package:flutter/material.dart';
import 'package:geniuswallet/controller/tag/menu_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class NavbarDesktop extends StatelessWidget {
  final constraints;
  final ovrWallet;
  final ovrShield;
  final ovrDex2;
  final ovrsettings;
  final ovrEllipseXor;
  NavbarDesktop(
    this.constraints, {
    Key key,
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
        width: 44.5,
        top: 17.5,
        height: 27.0,
        child: MenuCustom(
            child: Image.asset(
          'assets/images/182_1766.png',
          width: constraints.maxWidth * 44.500,
          height: constraints.maxHeight * 27.000,
        )),
      ),
      Positioned(
        right: 388.1,
        width: 98.9,
        top: 19.0,
        height: 28.5,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: 98.9,
            top: 0,
            height: 28.5,
            child: Container(
              width: constraints.maxWidth * 98.900,
              height: constraints.maxHeight * 28.500,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            width: 22.871,
            top: 0,
            height: 28.5,
            child: Image.asset(
              ovrShield ?? 'assets/images/0_12560.png',
              width: constraints.maxWidth * 22.871,
              height: constraints.maxHeight * 28.500,
            ),
          ),
          Positioned(
            left: 28.9,
            width: 70.0,
            top: 1.0,
            height: 27.0,
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
        ]),
      ),
      Positioned(
        right: 275.071,
        width: 73.529,
        top: 20.0,
        height: 27.0,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: 73.529,
            top: 0,
            height: 27.0,
            child: Container(
              width: constraints.maxWidth * 73.529,
              height: constraints.maxHeight * 27.000,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            width: 25.0,
            top: 4.88,
            height: 15.24,
            child: Image.asset(
              'assets/images/222_2546.png',
              width: constraints.maxWidth * 25.000,
              height: constraints.maxHeight * 15.240,
            ),
          ),
          Positioned(
            left: 37.529,
            width: 36.0,
            top: 0,
            height: 27.0,
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
        ]),
      ),
      Positioned(
        right: 125.2,
        width: 110.965,
        top: 20.0,
        height: 27.0,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: 24.168,
            top: 0.464,
            height: 24.169,
            child: Image.asset(
              ovrEllipseXor ?? 'assets/images/0_12570.png',
              width: constraints.maxWidth * 24.168,
              height: constraints.maxHeight * 24.169,
            ),
          ),
          Positioned(
            left: 0.825,
            width: 110.14,
            top: 0,
            height: 27.0,
            child: Container(
              width: constraints.maxWidth * 110.140,
              height: constraints.maxHeight * 27.000,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
          Positioned(
            left: 28.965,
            width: 82.0,
            top: 0,
            height: 27.0,
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
        ]),
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
      Positioned(
        right: 34.0,
        width: 67.0,
        top: 9.0,
        height: 50.0,
        child: Image.asset(
          'assets/images/222_3417.png',
          width: constraints.maxWidth * 67.000,
          height: constraints.maxHeight * 50.000,
        ),
      ),
    ]);
  }
}
