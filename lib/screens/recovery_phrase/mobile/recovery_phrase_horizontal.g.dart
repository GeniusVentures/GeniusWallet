import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/widgets/symbols/words.g.dart';
import 'package:geniuswallet/widgets/symbols/navigation_info.g.dart';
import 'package:geniuswallet/widgets/symbols/alert.g.dart';
import 'package:geniuswallet/widgets/symbols/cover_text_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/background_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/navbar_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/button_active.g.dart';

class RecoveryPhraseHorizontal extends StatefulWidget {
  const RecoveryPhraseHorizontal() : super();
  @override
  _RecoveryPhraseHorizontal createState() => _RecoveryPhraseHorizontal();
}

class _RecoveryPhraseHorizontal extends State<RecoveryPhraseHorizontal> {
  _RecoveryPhraseHorizontal();

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
              ovrShield: 'assets/images/I0_380;0_12560.png',
              ovrsettings: 'settings',
              ovrEllipseXor: 'assets/images/I0_380;0_12570.png',
              ovrDex2: 'Dex',
              ovrTriangle: 'assets/images/I0_380;0_12551.png',
              ovrAvatar: 'assets/images/I0_380;0_12550.png',
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
          left: MediaQuery.of(context).size.width * 0.315,
          width: MediaQuery.of(context).size.width * 0.371,
          top: MediaQuery.of(context).size.height * 0.114,
          height: MediaQuery.of(context).size.height * 0.285,
          child: LayoutBuilder(builder: (context, constraints) {
            return CoverTextDesktop(
              constraints,
              ovrTitle: 'Your recovery phrase',
              ovrLoremipsumdolorsitametco:
                  'Write down or copy these words in the right order and save them somewhere safe.',
              ovrNewshape: 'assets/images/I0_382;0_12689.png',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.371,
          width: MediaQuery.of(context).size.width * 0.084,
          top: MediaQuery.of(context).size.height * 0.491,
          height: MediaQuery.of(context).size.height * 0.04,
          child: LayoutBuilder(builder: (context, constraints) {
            return Words(
              constraints,
              ovrWord: '8 Mobile',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.538,
          width: MediaQuery.of(context).size.width * 0.09,
          top: MediaQuery.of(context).size.height * 0.491,
          height: MediaQuery.of(context).size.height * 0.04,
          child: LayoutBuilder(builder: (context, constraints) {
            return Words(
              constraints,
              ovrWord: '10 obvious',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.467,
          width: MediaQuery.of(context).size.width * 0.06,
          top: MediaQuery.of(context).size.height * 0.491,
          height: MediaQuery.of(context).size.height * 0.04,
          child: LayoutBuilder(builder: (context, constraints) {
            return Words(
              constraints,
              ovrWord: '9 visa',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.386,
          width: MediaQuery.of(context).size.width * 0.073,
          top: MediaQuery.of(context).size.height * 0.438,
          height: MediaQuery.of(context).size.height * 0.04,
          child: LayoutBuilder(builder: (context, constraints) {
            return Words(
              constraints,
              ovrWord: '5 Merge',
            );
          }),
        ),
        Positioned(
          left: 1492.9,
          width: 428.0,
          top: 577.001,
          height: 527.662,
          child: Image.asset(
            'assets/images/0_387.png',
            height: 527.662,
            width: 428.000,
          ),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.538,
          width: MediaQuery.of(context).size.width * 0.075,
          top: MediaQuery.of(context).size.height * 0.438,
          height: MediaQuery.of(context).size.height * 0.04,
          child: LayoutBuilder(builder: (context, constraints) {
            return Words(
              constraints,
              ovrWord: '7 winner',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.471,
          width: MediaQuery.of(context).size.width * 0.056,
          top: MediaQuery.of(context).size.height * 0.438,
          height: MediaQuery.of(context).size.height * 0.04,
          child: LayoutBuilder(builder: (context, constraints) {
            return Words(
              constraints,
              ovrWord: '6 toy',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.485,
          width: MediaQuery.of(context).size.width * 0.084,
          top: MediaQuery.of(context).size.height * 0.384,
          height: MediaQuery.of(context).size.height * 0.04,
          child: LayoutBuilder(builder: (context, constraints) {
            return Words(
              constraints,
              ovrWord: '3 Orphan',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.356,
          width: MediaQuery.of(context).size.width * 0.055,
          top: MediaQuery.of(context).size.height * 0.384,
          height: MediaQuery.of(context).size.height * 0.04,
          child: LayoutBuilder(builder: (context, constraints) {
            return Words(
              constraints,
              ovrWord: '1 limb',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.507,
          width: MediaQuery.of(context).size.width * 0.067,
          top: MediaQuery.of(context).size.height * 0.544,
          height: MediaQuery.of(context).size.height * 0.04,
          child: LayoutBuilder(builder: (context, constraints) {
            return Words(
              constraints,
              ovrWord: '12 style',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.427,
          width: MediaQuery.of(context).size.width * 0.069,
          top: MediaQuery.of(context).size.height * 0.544,
          height: MediaQuery.of(context).size.height * 0.04,
          child: LayoutBuilder(builder: (context, constraints) {
            return Words(
              constraints,
              ovrWord: '11 name',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.423,
          width: MediaQuery.of(context).size.width * 0.052,
          top: MediaQuery.of(context).size.height * 0.384,
          height: MediaQuery.of(context).size.height * 0.04,
          child: LayoutBuilder(builder: (context, constraints) {
            return Words(
              constraints,
              ovrWord: '2 ask',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.064,
          width: MediaQuery.of(context).size.width * 0.827,
          top: MediaQuery.of(context).size.height * 0.138,
          height: MediaQuery.of(context).size.height * 0.069,
          child: LayoutBuilder(builder: (context, constraints) {
            return NavigationInfo(
              constraints,
              ovri: 'i',
              ovrEllipse: 'assets/images/I0_422;0_12072.png',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.355,
          width: MediaQuery.of(context).size.width * 0.292,
          top: MediaQuery.of(context).size.height * 0.872,
          height: MediaQuery.of(context).size.height * 0.056,
          child: LayoutBuilder(builder: (context, constraints) {
            return ButtonActive(
              constraints,
              ovrTypesomething: 'Continue',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.581,
          width: MediaQuery.of(context).size.width * 0.063,
          top: MediaQuery.of(context).size.height * 0.384,
          height: MediaQuery.of(context).size.height * 0.04,
          child: LayoutBuilder(builder: (context, constraints) {
            return Words(
              constraints,
              ovrWord: '4 baby',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.462,
          width: MediaQuery.of(context).size.width * 0.077,
          top: MediaQuery.of(context).size.height * 0.642,
          height: MediaQuery.of(context).size.height * 0.041,
          child: Container(
              height: MediaQuery.of(context).size.height * 0.041,
              width: MediaQuery.of(context).size.width * 0.077,
              child: AutoSizeText(
                'Copy',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 28.799999237060547,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  letterSpacing: 0.0,
                  color: Color(0xff00f2ab),
                ),
                textAlign: TextAlign.center,
              )),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.355,
          width: MediaQuery.of(context).size.width * 0.292,
          top: MediaQuery.of(context).size.height * 0.733,
          height: MediaQuery.of(context).size.height * 0.097,
          child: LayoutBuilder(builder: (context, constraints) {
            return Alert(
              constraints,
              ovrNeversharerecoveryphrasewi:
                  'Never share recovery phrase with anyone, store it securely!',
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
