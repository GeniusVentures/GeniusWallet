import 'package:flutter/material.dart';
import 'package:geniuswallet/controller/genius_checkbox_custom.dart';
import 'package:geniuswallet/widgets/symbols/navbar_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/background_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/cover_text_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/genius_checkbox.g.dart';
import 'package:geniuswallet/widgets/symbols/navigation_back.g.dart';
import 'package:geniuswallet/widgets/symbols/button_inactive_desktop.g.dart';

class BackUpWalletHorizontal extends StatefulWidget {
  const BackUpWalletHorizontal() : super();
  @override
  _BackUpWalletHorizontal createState() => _BackUpWalletHorizontal();
}

class _BackUpWalletHorizontal extends State<BackUpWalletHorizontal> {
  _BackUpWalletHorizontal();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Stack(children: [
        Positioned(
          left: 2.0,
          right: 0,
          top: 0,
          bottom: 0,
          child: LayoutBuilder(builder: (context, constraints) {
            return BackgroundDesktop(
              constraints,
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.409,
          width: MediaQuery.of(context).size.width * 0.181,
          top: MediaQuery.of(context).size.height * 0.378,
          height: MediaQuery.of(context).size.height * 0.338,
          child: Center(
              child: Container(
                  width: 348.36956787109375,
                  child: Image.asset(
                    'assets/images/182_1705.png',
                    height: MediaQuery.of(context).size.height * 0.338,
                    width: 348.370,
                  ))),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.365,
          width: MediaQuery.of(context).size.width * 0.286,
          bottom: 121.0,
          height: 64.0,
          child: Center(
              child: Container(
                  width: 550.0,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return ButtonInactiveDesktop(
                      constraints,
                      ovrTypesomething: 'Continue',
                    );
                  }))),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.367,
          width: MediaQuery.of(context).size.width * 0.289,
          bottom: 226.0,
          height: 37.813,
          child: GeniusCheckboxCustom(
              child: LayoutBuilder(builder: (context, constraints) {
            return GeniusCheckbox(
              constraints,
              ovrThePropertyofAutonomousVer:
                  'I understand that if I lose my recovery words, I will not be able to access my wallet.',
            );
          })),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.14,
          width: MediaQuery.of(context).size.width * 0.718,
          top: 95.0,
          height: 411.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return CoverTextDesktop(
              constraints,
              ovrTitle: 'Back up your wallet now!',
              ovrLoremipsumdolorsitametco:
                  'In the next step you will see 12 words that allows you to recover a wallet.',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.104,
          width: MediaQuery.of(context).size.width * 0.391,
          top: 103.0,
          height: 74.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return NavigationBack(
              constraints,
            );
          }),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 67.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return NavbarDesktop(
              constraints,
              ovrWallet: 'Wallet',
              ovrShield: 'assets/images/I0_227;0_12560.png',
              ovrsettings: 'settings',
              ovrEllipseXor: 'assets/images/I0_227;0_12570.png',
              ovrDex2: 'Dex',
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
