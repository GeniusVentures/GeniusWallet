import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/widgets/symbols/cover_button_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/double_info.g.dart';
import 'package:geniuswallet/widgets/symbols/background_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/navbar_desktop.g.dart';

class NewWalletHorizontal extends StatefulWidget {
  const NewWalletHorizontal() : super();
  @override
  _NewWalletHorizontal createState() => _NewWalletHorizontal();
}

class _NewWalletHorizontal extends State<NewWalletHorizontal> {
  _NewWalletHorizontal();

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
              ovrShield: 'assets/images/I0_343;0_12560.png',
              ovrsettings: 'settings',
              ovrEllipseXor: 'assets/images/I0_343;0_12570.png',
              ovrDex2: 'Dex',
              ovrTriangle: 'assets/images/I0_343;0_12551.png',
              ovrAvatar: 'assets/images/I0_343;0_12550.png',
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
          left: MediaQuery.of(context).size.width * 0.518,
          width: MediaQuery.of(context).size.width * 0.352,
          top: MediaQuery.of(context).size.height * 0.309,
          height: MediaQuery.of(context).size.height * 0.381,
          child: LayoutBuilder(builder: (context, constraints) {
            return CoverButtonDesktop(
              constraints,
              ovrTitle:
                  'connect your wallet with walletconnect to make transactions',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.144,
          width: MediaQuery.of(context).size.width * 0.291,
          top: MediaQuery.of(context).size.height * 0.229,
          height: MediaQuery.of(context).size.height * 0.075,
          child: LayoutBuilder(builder: (context, constraints) {
            return DoubleInfo(
              constraints,
              ovrTypesomething: 'Buy Genius Tokens',
              ovrTypesomethingCopy: 'gnus.ai',
              ovrRectangle2: 'assets/images/I0_346;0_12279.png',
            );
          }),
        ),
        Positioned(
          left: 411.001,
          width: 288.0,
          top: 434.0,
          height: 448.0,
          child: Image.asset(
            'assets/images/0_347.png',
            height: 448.000,
            width: 288.000,
          ),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.144,
          width: MediaQuery.of(context).size.width * 0.128,
          top: MediaQuery.of(context).size.height * 0.16,
          height: MediaQuery.of(context).size.height * 0.045,
          child: Container(
              height: MediaQuery.of(context).size.height * 0.045,
              width: MediaQuery.of(context).size.width * 0.128,
              child: AutoSizeText(
                'Main wallet 1',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 32.29999923706055,
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.normal,
                  letterSpacing: 0.0,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
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
