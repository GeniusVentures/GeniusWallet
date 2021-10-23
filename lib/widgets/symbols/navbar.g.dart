import 'package:flutter/material.dart';
import 'package:geniuswallet/controller/wallet_tab.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/controller/dex_tab.dart';
import 'package:geniuswallet/controller/settings_tab.dart';

class Navbar extends StatelessWidget {
  final constraints;
  final ovrWallet;
  final ovrShield;
  final ovrDex;
  final ovrVector;
  final ovrsettings;
  final ovrEllipseXor;
  Navbar(
    this.constraints, {
    Key key,
    this.ovrWallet,
    this.ovrShield,
    this.ovrDex,
    this.ovrVector,
    this.ovrsettings,
    this.ovrEllipseXor,
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
        left: 38.1,
        width: 39.0,
        top: 9.5,
        height: 43.5,
        child: WalletTab(
            child: Stack(children: [
          Positioned(
            left: 0,
            width: 39.0,
            top: 0,
            height: 43.5,
            child: Container(
              width: constraints.maxWidth * 39.000,
              height: constraints.maxHeight * 43.500,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
          Positioned(
            left: 8.029,
            width: 22.871,
            top: 0,
            height: 28.5,
            child: Image.asset(
              ovrShield ?? 'assets/images/0_12369.png',
              width: constraints.maxWidth * 22.871,
              height: constraints.maxHeight * 28.500,
            ),
          ),
          Positioned(
            left: 0,
            width: 39.0,
            top: 28.5,
            height: 15.0,
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
        ])),
      ),
      Positioned(
        left: 175.0,
        width: 25.0,
        top: 13.643,
        height: 39.357,
        child: DexTab(
            child: Stack(children: [
          Positioned(
            left: 0,
            width: 25.0,
            top: 0,
            height: 39.357,
            child: Container(
              width: constraints.maxWidth * 25.000,
              height: constraints.maxHeight * 39.357,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            width: 25.0,
            top: 0,
            height: 17.244,
            child: Image.asset(
              ovrVector ?? 'assets/images/293_1712.png',
              width: constraints.maxWidth * 25.000,
              height: constraints.maxHeight * 17.244,
            ),
          ),
          Positioned(
            left: 2.1,
            width: 20.0,
            top: 24.357,
            height: 15.0,
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
        ])),
      ),
      Positioned(
        left: 296.0,
        width: 46.0,
        top: 11.789,
        height: 41.211,
        child: SettingsTab(
            child: Stack(children: [
          Positioned(
            left: 0,
            width: 46.0,
            top: 0,
            height: 41.211,
            child: Container(
              width: constraints.maxWidth * 46.000,
              height: constraints.maxHeight * 41.211,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
          Positioned(
            left: 11.789,
            width: 22.518,
            top: 0,
            height: 22.518,
            child: Image.asset(
              ovrEllipseXor ?? 'assets/images/0_12375.png',
              width: constraints.maxWidth * 22.518,
              height: constraints.maxHeight * 22.518,
            ),
          ),
          Positioned(
            left: 0,
            width: 46.0,
            top: 26.211,
            height: 15.0,
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
        ])),
      ),
    ]);
  }
}
