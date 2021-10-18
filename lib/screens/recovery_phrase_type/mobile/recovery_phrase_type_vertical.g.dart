import 'package:flutter/material.dart';
import 'package:geniuswallet/egg/recoveryphrasefield.dart';
import 'package:geniuswallet/egg/selections.dart';
import 'package:geniuswallet/egg/buttonactivecustom.dart';
import 'package:geniuswallet/widgets/symbols/words.g.dart';
import 'package:geniuswallet/widgets/symbols/button_inactive.g.dart';
import 'package:geniuswallet/widgets/symbols/cover_text.g.dart';
import 'package:geniuswallet/widgets/symbols/navigation_back.g.dart';

class RecoveryPhraseTypeVertical extends StatefulWidget {
  const RecoveryPhraseTypeVertical() : super();
  @override
  _RecoveryPhraseTypeVertical createState() => _RecoveryPhraseTypeVertical();
}

class _RecoveryPhraseTypeVertical extends State<RecoveryPhraseTypeVertical> {
  _RecoveryPhraseTypeVertical();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Stack(children: [
        Positioned(
          left: MediaQuery.of(context).size.width * 0.002,
          width: MediaQuery.of(context).size.width * 1.0,
          top: MediaQuery.of(context).size.height * 0.046,
          height: MediaQuery.of(context).size.height * 0.281,
          child: LayoutBuilder(builder: (context, constraints) {
            return CoverText(
              constraints,
              ovrTitle: 'Verify recovery phrase',
              ovrLoremipsumdolorsitametco:
                  'Tap the words to put them next to each other in the correct order',
            );
          }),
        ),
        Positioned(
          left: 33.156,
          right: 32.2,
          top: 321.0,
          height: 276.0,
          child: Stack(children: [
            Positioned(
              left: 0,
              width: MediaQuery.of(context).size.width * 0.827,
              top: 0,
              height: 276.0,
              child: Container(
                height: 276.000,
                width: MediaQuery.of(context).size.width * 0.827,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(0)),
                ),
              ),
            ),
            Positioned(
              left: 0,
              width: MediaQuery.of(context).size.width * 0.827,
              top: 0,
              height: 153.0,
              child: RecoveryPhraseField(
                  child: Image.asset(
                'assets/images/37_2996.png',
                height: 153.000,
                width: MediaQuery.of(context).size.width * 0.827,
              )),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.001,
              width: MediaQuery.of(context).size.width * 0.827,
              top: 170.0,
              height: 106.0,
              child: Selections(
                  child: Stack(children: [
                Positioned(
                  left: 0,
                  width: MediaQuery.of(context).size.width * 0.827,
                  top: 0,
                  height: 106.0,
                  child: Container(
                    height: 106.000,
                    width: MediaQuery.of(context).size.width * 0.827,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  width: MediaQuery.of(context).size.width * 0.171,
                  top: 0,
                  height: 28.909,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Words(
                      constraints,
                      ovrWord: 'Mobile',
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.205,
                  width: MediaQuery.of(context).size.width * 0.165,
                  top: 0,
                  height: 28.909,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Words(
                      constraints,
                      ovrWord: 'Merge',
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.405,
                  width: MediaQuery.of(context).size.width * 0.203,
                  top: 0,
                  height: 28.909,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Words(
                      constraints,
                      ovrWord: 'obvious',
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.643,
                  width: MediaQuery.of(context).size.width * 0.184,
                  top: 0,
                  height: 28.909,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Words(
                      constraints,
                      ovrWord: 'Orphan',
                    );
                  }),
                ),
                Positioned(
                  left: 0,
                  width: MediaQuery.of(context).size.width * 0.123,
                  top: 38.545,
                  height: 28.909,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Words(
                      constraints,
                      ovrWord: 'limb',
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.509,
                  width: MediaQuery.of(context).size.width * 0.137,
                  top: 38.545,
                  height: 28.909,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Words(
                      constraints,
                      ovrWord: 'style',
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.304,
                  width: MediaQuery.of(context).size.width * 0.168,
                  top: 38.545,
                  height: 28.909,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Words(
                      constraints,
                      ovrWord: 'winner',
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.188,
                  width: MediaQuery.of(context).size.width * 0.117,
                  top: 77.091,
                  height: 28.909,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Words(
                      constraints,
                      ovrWord: 'visa',
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.34,
                  width: MediaQuery.of(context).size.width * 0.099,
                  top: 77.091,
                  height: 28.909,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Words(
                      constraints,
                      ovrWord: 'ask',
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.473,
                  width: MediaQuery.of(context).size.width * 0.137,
                  top: 77.091,
                  height: 28.909,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Words(
                      constraints,
                      ovrWord: 'baby',
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.68,
                  width: MediaQuery.of(context).size.width * 0.147,
                  top: 38.545,
                  height: 28.909,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Words(
                      constraints,
                      ovrWord: 'name',
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.157,
                  width: MediaQuery.of(context).size.width * 0.112,
                  top: 38.545,
                  height: 28.909,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Words(
                      constraints,
                      ovrWord: 'toy',
                    );
                  }),
                ),
              ])),
            ),
          ]),
        ),
        Positioned(
          left: 33.156,
          right: 32.5,
          top: MediaQuery.of(context).size.height * 0.889,
          height: MediaQuery.of(context).size.height * 0.055,
          child: ButtonActiveCustom(
              child: LayoutBuilder(builder: (context, constraints) {
            return ButtonInactive(
              constraints,
              ovrTypesomething: 'Continue',
            );
          })),
        ),
        Positioned(
          left: 0,
          width: MediaQuery.of(context).size.width * 1.0,
          top: MediaQuery.of(context).size.height * 0.064,
          height: MediaQuery.of(context).size.height * 0.046,
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
