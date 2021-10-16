import 'package:flutter/material.dart';
import 'package:geniuswallet/egg/buttonactivecustom.dart';
import 'package:geniuswallet/egg/geniuscheckboxcustom.dart';
import 'package:geniuswallet/widgets/symbols/genius_checkbox.g.dart';
import 'package:geniuswallet/widgets/symbols/navigation_back.g.dart';
import 'package:geniuswallet/widgets/symbols/button_inactive.g.dart';
import 'package:geniuswallet/widgets/symbols/cover_text.g.dart';

class BackUpWalletVertical extends StatefulWidget {
  const BackUpWalletVertical() : super();
  @override
  _BackUpWalletVertical createState() => _BackUpWalletVertical();
}

class _BackUpWalletVertical extends State<BackUpWalletVertical> {
  _BackUpWalletVertical();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Stack(children: [
        Positioned(
          left: 80.483,
          right: 79.997,
          top: 385.5,
          height: 225.3,
          child: Image.asset(
            'assets/images/165_1699.png',
            height: 225.300,
            width: MediaQuery.of(context).size.width * 0.573,
          ),
        ),
        Positioned(
          left: 0.456,
          right: 0,
          top: 37.0,
          height: 228.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return CoverText(
              constraints,
              ovrTitle: 'Back up your wallet now!',
              ovrLoremipsumdolorsitametco:
                  'In the next step you will see 12 words that allows you to recover a wallet.',
            );
          }),
        ),
        Positioned(
          left: 32.956,
          right: 32.5,
          top: 722.0,
          height: 45.0,
          child: ButtonActiveCustom(
              child: LayoutBuilder(builder: (context, constraints) {
            return ButtonInactive(
              constraints,
              ovrTypesomething: 'Continue',
            );
          })),
        ),
        Positioned(
          left: 35.01,
          right: 32.446,
          top: 678.0,
          height: 21.0,
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
          left: 0,
          width: 375.0,
          top: 51.963,
          height: 37.0,
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
