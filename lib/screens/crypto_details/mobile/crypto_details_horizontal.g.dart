import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/widgets/symbols/contracts.g.dart';
import 'package:geniuswallet/widgets/symbols/cover_crypto_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/background_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/navbar_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/button_active.g.dart';

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
              ovrTriangle: 'assets/images/I0_273;0_12551.png',
              ovrAvatar: 'assets/images/I0_273;0_12550.png',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.18,
          width: MediaQuery.of(context).size.width * 0.291,
          top: MediaQuery.of(context).size.height * 0.612,
          height: MediaQuery.of(context).size.height * 0.075,
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
          left: MediaQuery.of(context).size.width * 0.18,
          width: MediaQuery.of(context).size.width * 0.291,
          top: MediaQuery.of(context).size.height * 0.512,
          height: MediaQuery.of(context).size.height * 0.075,
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
          left: MediaQuery.of(context).size.width * 0.181,
          width: MediaQuery.of(context).size.width * 0.291,
          top: MediaQuery.of(context).size.height * 0.412,
          height: MediaQuery.of(context).size.height * 0.075,
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
          left: MediaQuery.of(context).size.width * 0.52,
          width: MediaQuery.of(context).size.width * 0.352,
          top: MediaQuery.of(context).size.height * 0.114,
          height: MediaQuery.of(context).size.height * 0.467,
          child: LayoutBuilder(builder: (context, constraints) {
            return CoverCryptoDesktop(
              constraints,
              ovrTitle: 'ethereum',
              ovr4630950: '\$46,309.50',
              ovr418: '+4.18%',
              ovrEllipse: 'assets/images/I0_284;0_12664.png',
              ovrText: '~ \$21.03',
              ovrAmount: '0.0065218 ETH',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.18,
          width: MediaQuery.of(context).size.width * 0.291,
          top: MediaQuery.of(context).size.height * 0.312,
          height: MediaQuery.of(context).size.height * 0.075,
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
          left: MediaQuery.of(context).size.width * 0.18,
          width: MediaQuery.of(context).size.width * 0.291,
          top: MediaQuery.of(context).size.height * 0.212,
          height: MediaQuery.of(context).size.height * 0.075,
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
          top: MediaQuery.of(context).size.height * 0.773,
          height: MediaQuery.of(context).size.height * 0.075,
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
          left: MediaQuery.of(context).size.width * 0.18,
          width: MediaQuery.of(context).size.width * 0.064,
          top: MediaQuery.of(context).size.height * 0.153,
          height: MediaQuery.of(context).size.height * 0.035,
          child: Container(
              height: MediaQuery.of(context).size.height * 0.035,
              width: MediaQuery.of(context).size.width * 0.064,
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
          left: MediaQuery.of(context).size.width * 0.18,
          width: MediaQuery.of(context).size.width * 0.067,
          top: MediaQuery.of(context).size.height * 0.712,
          height: MediaQuery.of(context).size.height * 0.035,
          child: Container(
              height: MediaQuery.of(context).size.height * 0.035,
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
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
