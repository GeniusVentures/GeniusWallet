import 'package:flutter/material.dart';
import 'package:geniuswallet/widgets/symbols/words.g.dart';
import 'package:geniuswallet/widgets/symbols/cover_text_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/background_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/navbar_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/button_inactive.g.dart';

class RecoveryPhraseTypeHorizontal extends StatefulWidget {
  const RecoveryPhraseTypeHorizontal() : super();
  @override
  _RecoveryPhraseTypeHorizontal createState() =>
      _RecoveryPhraseTypeHorizontal();
}

class _RecoveryPhraseTypeHorizontal
    extends State<RecoveryPhraseTypeHorizontal> {
  _RecoveryPhraseTypeHorizontal();

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
              ovrShield: 'assets/images/I0_428;0_12560.png',
              ovrsettings: 'settings',
              ovrEllipseXor: 'assets/images/I0_428;0_12570.png',
              ovrDex2: 'Dex',
              ovrTriangle: 'assets/images/I0_428;0_12551.png',
              ovrAvatar: 'assets/images/I0_428;0_12550.png',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.355,
          width: MediaQuery.of(context).size.width * 0.06,
          top: MediaQuery.of(context).size.height * 0.639,
          height: MediaQuery.of(context).size.height * 0.04,
          child: LayoutBuilder(builder: (context, constraints) {
            return Words(
              constraints,
              ovrWord: 'Mobile',
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
          left: MediaQuery.of(context).size.width * 0.427,
          width: MediaQuery.of(context).size.width * 0.058,
          top: MediaQuery.of(context).size.height * 0.639,
          height: MediaQuery.of(context).size.height * 0.04,
          child: LayoutBuilder(builder: (context, constraints) {
            return Words(
              constraints,
              ovrWord: 'Merge',
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
              ovrTitle: 'Verify recovery phrase',
              ovrLoremipsumdolorsitametco:
                  'Tap the words to put them next to each other in the correct order',
              ovrNewshape: 'assets/images/I0_430;0_12689.png',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.497,
          width: MediaQuery.of(context).size.width * 0.071,
          top: MediaQuery.of(context).size.height * 0.639,
          height: MediaQuery.of(context).size.height * 0.04,
          child: LayoutBuilder(builder: (context, constraints) {
            return Words(
              constraints,
              ovrWord: 'obvious',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.581,
          width: MediaQuery.of(context).size.width * 0.065,
          top: MediaQuery.of(context).size.height * 0.639,
          height: MediaQuery.of(context).size.height * 0.04,
          child: LayoutBuilder(builder: (context, constraints) {
            return Words(
              constraints,
              ovrWord: 'Orphan',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.353,
          width: MediaQuery.of(context).size.width * 0.293,
          top: MediaQuery.of(context).size.height * 0.871,
          height: MediaQuery.of(context).size.height * 0.056,
          child: LayoutBuilder(builder: (context, constraints) {
            return ButtonInactive(
              constraints,
              ovrTypesomething: 'Continue',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.351,
          width: MediaQuery.of(context).size.width * 0.299,
          top: MediaQuery.of(context).size.height * 0.338,
          height: MediaQuery.of(context).size.height * 0.262,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.262,
            width: MediaQuery.of(context).size.width * 0.299,
            decoration: BoxDecoration(
              color: Color(0xff0068ef),
              borderRadius: BorderRadius.all(Radius.circular(0)),
            ),
          ),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.355,
          width: MediaQuery.of(context).size.width * 0.043,
          top: MediaQuery.of(context).size.height * 0.692,
          height: MediaQuery.of(context).size.height * 0.04,
          child: LayoutBuilder(builder: (context, constraints) {
            return Words(
              constraints,
              ovrWord: 'limb',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.533,
          width: MediaQuery.of(context).size.width * 0.048,
          top: MediaQuery.of(context).size.height * 0.692,
          height: MediaQuery.of(context).size.height * 0.04,
          child: LayoutBuilder(builder: (context, constraints) {
            return Words(
              constraints,
              ovrWord: 'style',
            );
          }),
        ),
        Positioned(
          left: 1492.9,
          width: 428.0,
          top: 577.001,
          height: 527.662,
          child: Image.asset(
            'assets/images/0_446.png',
            height: 527.662,
            width: 428.000,
          ),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.462,
          width: MediaQuery.of(context).size.width * 0.059,
          top: MediaQuery.of(context).size.height * 0.692,
          height: MediaQuery.of(context).size.height * 0.04,
          child: LayoutBuilder(builder: (context, constraints) {
            return Words(
              constraints,
              ovrWord: 'winner',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.421,
          width: MediaQuery.of(context).size.width * 0.041,
          top: MediaQuery.of(context).size.height * 0.746,
          height: MediaQuery.of(context).size.height * 0.04,
          child: LayoutBuilder(builder: (context, constraints) {
            return Words(
              constraints,
              ovrWord: 'visa',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.474,
          width: MediaQuery.of(context).size.width * 0.035,
          top: MediaQuery.of(context).size.height * 0.746,
          height: MediaQuery.of(context).size.height * 0.04,
          child: LayoutBuilder(builder: (context, constraints) {
            return Words(
              constraints,
              ovrWord: 'ask',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.521,
          width: MediaQuery.of(context).size.width * 0.048,
          top: MediaQuery.of(context).size.height * 0.746,
          height: MediaQuery.of(context).size.height * 0.04,
          child: LayoutBuilder(builder: (context, constraints) {
            return Words(
              constraints,
              ovrWord: 'baby',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.594,
          width: MediaQuery.of(context).size.width * 0.052,
          top: MediaQuery.of(context).size.height * 0.692,
          height: MediaQuery.of(context).size.height * 0.04,
          child: LayoutBuilder(builder: (context, constraints) {
            return Words(
              constraints,
              ovrWord: 'name',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.41,
          width: MediaQuery.of(context).size.width * 0.039,
          top: MediaQuery.of(context).size.height * 0.692,
          height: MediaQuery.of(context).size.height * 0.04,
          child: LayoutBuilder(builder: (context, constraints) {
            return Words(
              constraints,
              ovrWord: 'toy',
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
