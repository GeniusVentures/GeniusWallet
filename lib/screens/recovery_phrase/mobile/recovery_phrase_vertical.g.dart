import 'package:flutter/material.dart';
import 'package:geniuswallet/controller/recovery_phrase_selections.dart';
import 'package:geniuswallet/controller/button_active_custom.dart';
import 'package:geniuswallet/controller/copy.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/widgets/symbols/words.g.dart';
import 'package:geniuswallet/widgets/symbols/alert.g.dart';
import 'package:geniuswallet/widgets/symbols/navigation_info.g.dart';
import 'package:geniuswallet/widgets/symbols/button_active.g.dart';
import 'package:geniuswallet/widgets/symbols/cover_text.g.dart';

class RecoveryPhraseVertical extends StatefulWidget {
  const RecoveryPhraseVertical() : super();
  @override
  _RecoveryPhraseVertical createState() => _RecoveryPhraseVertical();
}

class _RecoveryPhraseVertical extends State<RecoveryPhraseVertical> {
  _RecoveryPhraseVertical();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Stack(children: [
        Positioned(
          left: 0.456,
          right: 0,
          top: 37.0,
          height: 228.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return CoverText(
              constraints,
              ovrTitle: 'Your recovery phrase',
              ovrLoremipsumdolorsitametco:
                  'Write down or copy these words in the right order and save them somewhere safe.',
            );
          }),
        ),
        Positioned(
          left: 34.456,
          right: 34.0,
          top: 327.0,
          height: 140.0,
          child: RecoveryPhraseSelections(
              child: Stack(children: [
            Positioned(
              left: 0,
              width: MediaQuery.of(context).size.width * 0.819,
              top: 0,
              height: 140.0,
              child: Container(
                height: 140.000,
                width: MediaQuery.of(context).size.width * 0.819,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(0)),
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.043,
              width: MediaQuery.of(context).size.width * 0.24,
              top: 74.667,
              height: 28.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return Words(
                  constraints,
                  ovrWord: '8 Mobile',
                );
              }),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.518,
              width: MediaQuery.of(context).size.width * 0.256,
              top: 74.667,
              height: 28.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return Words(
                  constraints,
                  ovrWord: '10 obvious',
                );
              }),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.315,
              width: MediaQuery.of(context).size.width * 0.171,
              top: 74.667,
              height: 28.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return Words(
                  constraints,
                  ovrWord: '9 visa',
                );
              }),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.086,
              width: MediaQuery.of(context).size.width * 0.208,
              top: 37.333,
              height: 28.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return Words(
                  constraints,
                  ovrWord: '5 Merge',
                );
              }),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.518,
              width: MediaQuery.of(context).size.width * 0.213,
              top: 37.333,
              height: 28.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return Words(
                  constraints,
                  ovrWord: '7 winner',
                );
              }),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.326,
              width: MediaQuery.of(context).size.width * 0.16,
              top: 37.333,
              height: 28.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return Words(
                  constraints,
                  ovrWord: '6 toy',
                );
              }),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.368,
              width: MediaQuery.of(context).size.width * 0.24,
              top: 0,
              height: 28.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return Words(
                  constraints,
                  ovrWord: '3 Orphan',
                );
              }),
            ),
            Positioned(
              left: 0,
              width: MediaQuery.of(context).size.width * 0.157,
              top: 0,
              height: 28.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return Words(
                  constraints,
                  ovrWord: '1 limb',
                );
              }),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.43,
              width: MediaQuery.of(context).size.width * 0.189,
              top: 112.0,
              height: 28.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return Words(
                  constraints,
                  ovrWord: '12 style',
                );
              }),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.201,
              width: MediaQuery.of(context).size.width * 0.197,
              top: 112.0,
              height: 28.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return Words(
                  constraints,
                  ovrWord: '11 name',
                );
              }),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.189,
              width: MediaQuery.of(context).size.width * 0.147,
              top: 0,
              height: 28.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return Words(
                  constraints,
                  ovrWord: '2 ask',
                );
              }),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.64,
              width: MediaQuery.of(context).size.width * 0.179,
              top: 0,
              height: 28.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return Words(
                  constraints,
                  ovrWord: '4 baby',
                );
              }),
            ),
          ])),
        ),
        Positioned(
          left: 0,
          right: 0.456,
          top: 48.963,
          height: 37.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return NavigationInfo(
              constraints,
              ovri: 'i',
              ovrEllipse: 'assets/images/I0_142;0_12072.png',
            );
          }),
        ),
        Positioned(
          left: 32.456,
          right: 33.0,
          bottom: 44.153,
          height: 45.0,
          child: ButtonActiveCustom(
              child: LayoutBuilder(builder: (context, constraints) {
            return ButtonActive(
              constraints,
              ovrTypesomething: 'Continue',
            );
          })),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.447,
          width: MediaQuery.of(context).size.width * 0.109,
          top: 487.0,
          height: 24.0,
          child: Center(
              child: Container(
                  width: 41.0,
                  child: Copy(
                      child: AutoSizeText(
                    'Copy',
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      letterSpacing: 0.0,
                      color: Color(0xff00f2ab),
                    ),
                    textAlign: TextAlign.center,
                  )))),
        ),
        Positioned(
          left: 33.456,
          right: 31.0,
          bottom: 108.0,
          height: 56.0,
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
