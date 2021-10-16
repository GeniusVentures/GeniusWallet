import 'package:flutter/material.dart';
import 'package:geniuswallet/egg/geniuscheckboxcustom.dart';
import 'package:geniuswallet/widgets/symbols/genius_checkbox.g.dart';
import 'package:geniuswallet/widgets/symbols/cover_text_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/background_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/navigation_back.g.dart';
import 'package:geniuswallet/widgets/symbols/navbar_desktop.g.dart';
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
          left: 0,
          width: 1920.0,
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
              ovrTriangle: 'assets/images/I0_227;0_12551.png',
              ovrAvatar: 'assets/images/I0_227;0_12550.png',
            );
          }),
        ),
        Positioned(
          left: 704.397,
          width: 554.4,
          top: 841.187,
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
          left: 2.0,
          width: 1918.0,
          top: 0,
          height: 1080.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return BackgroundDesktop(
              constraints,
            );
          }),
        ),
        Positioned(
          left: 785.868,
          width: 348.37,
          top: 407.9,
          height: 365.099,
          child: Image.asset(
            'assets/images/0_229.png',
            height: 365.099,
            width: 348.370,
          ),
        ),
        Positioned(
          left: 701.2,
          width: 550.0,
          top: 920.0,
          height: 64.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return ButtonInactiveDesktop(
              constraints,
              ovrTypesomething: 'Continue',
            );
          }),
        ),
        Positioned(
          left: 622.0,
          width: 675.0,
          top: 95.0,
          height: 411.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return CoverTextDesktop(
              constraints,
              ovrTitle: 'Back up your wallet now!',
              ovrLoremipsumdolorsitametco:
                  'In the next step you will see 12 words that allows you to recover a wallet.',
              ovrNewshape: 'assets/images/I0_259;0_12689.png',
            );
          }),
        ),
        Positioned(
          left: 199.0,
          width: 750.0,
          top: 90.0,
          height: 74.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return NavigationBack(
              constraints,
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
