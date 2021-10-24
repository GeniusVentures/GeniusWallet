import 'package:flutter/material.dart';
import 'package:geniuswallet/controller/tag/cryto_details_scroll_view.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/widgets/symbols/navbar.g.dart';
import 'package:geniuswallet/widgets/symbols/navigation_buy.g.dart';
import 'package:geniuswallet/widgets/symbols/contracts.g.dart';
import 'package:geniuswallet/widgets/symbols/cover_crypto.g.dart';

class CryptoDetailsVertical extends StatefulWidget {
  const CryptoDetailsVertical() : super();
  @override
  _CryptoDetailsVertical createState() => _CryptoDetailsVertical();
}

class _CryptoDetailsVertical extends State<CryptoDetailsVertical> {
  _CryptoDetailsVertical();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Stack(children: [
        Positioned(
          left: MediaQuery.of(context).size.width * 0.001,
          width: MediaQuery.of(context).size.width * 1.0,
          top: 37.0,
          height: 280.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return CoverCrypto(
              constraints,
              ovrTitle: 'ethereum',
              ovr4630950: '\$46,309.50',
              ovr418: '+4.18%',
              ovrEllipse: 'assets/images/I0_121;0_12183.png',
              ovrText: '~ \$21.03',
              ovrAmount: '0.0065218 ETH',
            );
          }),
        ),
        Positioned(
          left: 32.456,
          right: 32.0,
          top: 341.0,
          height: 394.0,
          child: CrytoDetailsScrollView(
              child: Stack(children: [
            Positioned(
              left: 0,
              width: MediaQuery.of(context).size.width * 0.829,
              top: 0,
              height: 394.0,
              child: Container(
                height: 394.000,
                width: MediaQuery.of(context).size.width * 0.829,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(0)),
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.001,
              width: MediaQuery.of(context).size.width * 0.827,
              top: 275.479,
              height: 45.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return Contracts(
                  constraints,
                  ovrSmartContractCall: 'Smart Contract Call',
                  ovrETH: 'ETH',
                  ovrTo0x033526b9bF6: 'To: 0x03352...6b9bF6',
                );
              }),
            ),
            Positioned(
              left: 0,
              width: MediaQuery.of(context).size.width * 0.827,
              top: 215.6,
              height: 45.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return Contracts(
                  constraints,
                  ovrSmartContractCall: 'Smart Contract Call',
                  ovrETH: 'ETH',
                  ovrTo0x033526b9bF6: 'To: 0x03352...6b9bF6',
                );
              }),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.003,
              width: MediaQuery.of(context).size.width * 0.827,
              top: 155.7,
              height: 45.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return Contracts(
                  constraints,
                  ovrSmartContractCall: 'Smart Contract Call',
                  ovrETH: 'ETH',
                  ovrTo0x033526b9bF6: 'To: 0x03352...6b9bF6',
                );
              }),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.002,
              width: MediaQuery.of(context).size.width * 0.827,
              top: 95.8,
              height: 45.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return Contracts(
                  constraints,
                  ovrSmartContractCall: 'Smart Contract Call',
                  ovrETH: 'ETH',
                  ovrTo0x033526b9bF6: 'To: 0x03352...6b9bF6',
                );
              }),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.002,
              width: MediaQuery.of(context).size.width * 0.827,
              top: 35.922,
              height: 45.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return Contracts(
                  constraints,
                  ovrSmartContractCall: 'Smart Contract Call',
                  ovrETH: 'ETH',
                  ovrTo0x033526b9bF6: 'To: 0x03352...6b9bF6',
                );
              }),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.001,
              width: MediaQuery.of(context).size.width * 0.827,
              top: 372.178,
              height: 45.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return Contracts(
                  constraints,
                  ovrSmartContractCall: 'Smart Contract Call',
                  ovrETH: 'ETH',
                  ovrTo0x033526b9bF6: 'To: 0x03352...6b9bF6',
                );
              }),
            ),
            Positioned(
              left: 0.6,
              width: 68.0,
              top: 0,
              height: 21.0,
              child: Container(
                  height: 21.000,
                  width: 68.000,
                  child: AutoSizeText(
                    'Yesterday',
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      letterSpacing: 0.0,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.left,
                  )),
            ),
            Positioned(
              left: 0.6,
              width: 72.0,
              top: 335.8,
              height: 21.0,
              child: Container(
                  height: 21.000,
                  width: 72.000,
                  child: AutoSizeText(
                    'Past Week',
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      letterSpacing: 0.0,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.left,
                  )),
            ),
          ])),
        ),
        Positioned(
          left: 0,
          right: 0.456,
          top: 48.963,
          height: 37.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return NavigationBuy(
              constraints,
            );
          }),
        ),
        Positioned(
          left: 0.456,
          right: 0,
          bottom: 0,
          height: 77.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return Navbar(
              constraints,
              ovrWallet: 'Wallet',
              ovrShield: 'assets/images/I0_131;0_12369.png',
              ovrDex: 'Dex',
              ovrsettings: 'settings',
              ovrEllipseXor: 'assets/images/I0_131;0_12375.png',
            );
          }),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
