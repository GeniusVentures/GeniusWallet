import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/widgets/symbols/contracts_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/navbar_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/background_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/button_active.g.dart';
import 'package:geniuswallet/widgets/symbols/cover_crypto_desktop.g.dart';

class CryptoDetailsHorizontal extends StatefulWidget {
  const CryptoDetailsHorizontal() : super();
  @override
  _CryptoDetailsHorizontal createState() => _CryptoDetailsHorizontal();
}

class _CryptoDetailsHorizontal extends State<CryptoDetailsHorizontal> {
  _CryptoDetailsHorizontal();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Stack(children: [
        Positioned(
          left: MediaQuery.of(context).size.width * 0.001,
          width: MediaQuery.of(context).size.width * 0.999,
          top: 0,
          height: MediaQuery.of(context).size.height * 1.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return BackgroundDesktop(
              constraints,
            );
          }),
        ),
        Positioned(
          left: 0,
          width: MediaQuery.of(context).size.width * 1.0,
          top: 0,
          height: MediaQuery.of(context).size.height * 0.062,
          child: LayoutBuilder(builder: (context, constraints) {
            return NavbarDesktop(
              constraints,
              ovrWallet: 'Wallet',
              ovrShield: 'assets/images/I0_273;0_12560.png',
              ovrsettings: 'settings',
              ovrEllipseXor: 'assets/images/I0_273;0_12570.png',
              ovrDex2: 'Dex',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.52,
          width: MediaQuery.of(context).size.width * 0.353,
          top: 123.0,
          height: 528.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return CoverCryptoDesktop(
              constraints,
              ovrTitle: 'ethereum',
              ovrEllipse: 'assets/images/I0_284;0_12664.png',
              ovrText: '~ \$21.03',
              ovrAmount: '0.0065218 ETH',
              ovr418: '+4.18%',
              ovr4630950: '\$46,309.50',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.559,
          width: MediaQuery.of(context).size.width * 0.274,
          top: MediaQuery.of(context).size.height * 0.647,
          height: MediaQuery.of(context).size.height * 0.056,
          child: LayoutBuilder(builder: (context, constraints) {
            return ButtonActive(
              constraints,
              ovrTypesomething: 'Buy',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.559,
          width: MediaQuery.of(context).size.width * 0.274,
          top: MediaQuery.of(context).size.height * 0.717,
          height: MediaQuery.of(context).size.height * 0.056,
          child: LayoutBuilder(builder: (context, constraints) {
            return ButtonActive(
              constraints,
              ovrTypesomething: 'Chart',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.18,
          width: MediaQuery.of(context).size.width * 0.291,
          top: 164.779,
          height: 750.221,
          child: Stack(children: [
            Positioned(
              left: 0,
              width: MediaQuery.of(context).size.width * 0.291,
              top: 0,
              height: 750.221,
              child: Container(
                height: 750.221,
                width: MediaQuery.of(context).size.width * 0.291,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(0)),
                ),
              ),
            ),
            Positioned(
              left: 0.945,
              width: 122.0,
              top: 0,
              height: 38.0,
              child: Container(
                  height: 38.000,
                  width: 122.000,
                  child: AutoSizeText(
                    'Yesterday',
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 25.0,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      letterSpacing: 0.0,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.left,
                  )),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.001,
              width: MediaQuery.of(context).size.width * 0.067,
              top: 604.321,
              height: 38.0,
              child: Container(
                  height: 38.000,
                  width: MediaQuery.of(context).size.width * 0.067,
                  child: AutoSizeText(
                    'Past Week',
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 25.0,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      letterSpacing: 0.0,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.left,
                  )),
            ),
            Positioned(
              left: 0,
              width: MediaQuery.of(context).size.width * 0.291,
              top: 668.221,
              height: 82.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return ContractsDesktop(
                  constraints,
                  ovrSmartContractCall: 'Smart Contract Call',
                  ovrETH: 'ETH',
                  ovrTo0x033526b9bF6: 'To: 0x03352...6b9bF6',
                );
              }),
            ),
            Positioned(
              left: 0,
              width: MediaQuery.of(context).size.width * 0.291,
              top: 498.221,
              height: 82.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return ContractsDesktop(
                  constraints,
                  ovrSmartContractCall: 'Smart Contract Call',
                  ovrETH: 'ETH',
                  ovrTo0x033526b9bF6: 'To: 0x03352...6b9bF6',
                );
              }),
            ),
            Positioned(
              left: 0,
              width: MediaQuery.of(context).size.width * 0.291,
              top: 391.221,
              height: 82.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return ContractsDesktop(
                  constraints,
                  ovrSmartContractCall: 'Smart Contract Call',
                  ovrETH: 'ETH',
                  ovrTo0x033526b9bF6: 'To: 0x03352...6b9bF6',
                );
              }),
            ),
            Positioned(
              left: 0,
              width: MediaQuery.of(context).size.width * 0.291,
              top: 281.221,
              height: 82.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return ContractsDesktop(
                  constraints,
                  ovrSmartContractCall: 'Smart Contract Call',
                  ovrETH: 'ETH',
                  ovrTo0x033526b9bF6: 'To: 0x03352...6b9bF6',
                );
              }),
            ),
            Positioned(
              left: 0,
              width: MediaQuery.of(context).size.width * 0.291,
              top: 173.221,
              height: 82.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return ContractsDesktop(
                  constraints,
                  ovrSmartContractCall: 'Smart Contract Call',
                  ovrETH: 'ETH',
                  ovrTo0x033526b9bF6: 'To: 0x03352...6b9bF6',
                );
              }),
            ),
            Positioned(
              left: 0,
              width: MediaQuery.of(context).size.width * 0.291,
              top: 65.221,
              height: 82.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return ContractsDesktop(
                  constraints,
                  ovrSmartContractCall: 'Smart Contract Call',
                  ovrETH: 'ETH',
                  ovrTo0x033526b9bF6: 'To: 0x03352...6b9bF6',
                );
              }),
            ),
          ]),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
