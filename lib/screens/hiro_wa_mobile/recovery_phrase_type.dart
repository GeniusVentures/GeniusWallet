import 'package:flutter/material.dart';
import '../../view/symbols/cover_text.dart';
import '../../view/symbols/navigation_back.dart';
import '../../view/symbols/words.dart';
import '../../view/symbols/button_inactive.dart';

class RecoveryPhraseType extends StatefulWidget {
  const RecoveryPhraseType() : super();
  @override
  _RecoveryPhraseType createState() => _RecoveryPhraseType();
}

class _RecoveryPhraseType extends State<RecoveryPhraseType> {
  _RecoveryPhraseType();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Align(
        alignment: Alignment(0.39, -0.10),
        child: Container(
            width: MediaQuery.of(context).size.width * 1.002,
            height: MediaQuery.of(context).size.height * 0.899,
            child: Align(
              alignment: Alignment(0.00, 0.00),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 32,
                      child: Padding(
                          padding: EdgeInsets.only(),
                          child: Container(
                              width: MediaQuery.of(context).size.width * 1.002,
                              height:
                                  MediaQuery.of(context).size.height * 0.281,
                              child: Align(
                                alignment: Alignment(0.00, 0.00),
                                child: Stack(children: [
                                  Positioned(
                                    left: MediaQuery.of(context).size.width *
                                        0.002,
                                    right: MediaQuery.of(context).size.width *
                                        0.000,
                                    top: MediaQuery.of(context).size.height *
                                        0.000,
                                    bottom: MediaQuery.of(context).size.height *
                                        0.000,
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return CoverText(
                                        constraints,
                                      );
                                    }),
                                  ),
                                  Positioned(
                                    left: MediaQuery.of(context).size.width *
                                        0.000,
                                    right: MediaQuery.of(context).size.width *
                                        0.002,
                                    top: MediaQuery.of(context).size.height *
                                        0.018,
                                    bottom: MediaQuery.of(context).size.height *
                                        0.217,
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return NavigationBack(
                                        constraints,
                                      );
                                    }),
                                  ),
                                ]),
                              ))),
                    ),
                    Spacer(
                      flex: 8,
                    ),
                    Flexible(
                      flex: 21,
                      child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.09,
                            right: MediaQuery.of(context).size.width * 0.09,
                          ),
                          child: Image.asset(
                            'assets/images/37_2996.png',
                            width: MediaQuery.of(context).size.width * 0.827,
                            height: MediaQuery.of(context).size.height * 0.188,
                          )),
                    ),
                    Spacer(
                      flex: 3,
                    ),
                    Flexible(
                      flex: 13,
                      child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.09,
                            right: MediaQuery.of(context).size.width * 0.09,
                          ),
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.827,
                              height:
                                  MediaQuery.of(context).size.height * 0.108,
                              child: Align(
                                alignment: Alignment(0.00, 0.00),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        flex: 28,
                                        child: Padding(
                                            padding: EdgeInsets.only(),
                                            child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.827,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.030,
                                                child: Align(
                                                  alignment:
                                                      Alignment(0.00, 0.00),
                                                  child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Flexible(
                                                          flex: 21,
                                                          child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(),
                                                              child: LayoutBuilder(
                                                                  builder: (context,
                                                                      constraints) {
                                                                return Words(
                                                                  constraints,
                                                                );
                                                              })),
                                                        ),
                                                        Spacer(
                                                          flex: 5,
                                                        ),
                                                        Flexible(
                                                          flex: 20,
                                                          child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(),
                                                              child: LayoutBuilder(
                                                                  builder: (context,
                                                                      constraints) {
                                                                return Words(
                                                                  constraints,
                                                                );
                                                              })),
                                                        ),
                                                        Spacer(
                                                          flex: 5,
                                                        ),
                                                        Flexible(
                                                          flex: 25,
                                                          child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(),
                                                              child: LayoutBuilder(
                                                                  builder: (context,
                                                                      constraints) {
                                                                return Words(
                                                                  constraints,
                                                                );
                                                              })),
                                                        ),
                                                        Spacer(
                                                          flex: 5,
                                                        ),
                                                        Flexible(
                                                          flex: 23,
                                                          child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(),
                                                              child: LayoutBuilder(
                                                                  builder: (context,
                                                                      constraints) {
                                                                return Words(
                                                                  constraints,
                                                                );
                                                              })),
                                                        )
                                                      ]),
                                                ))),
                                      ),
                                      Spacer(
                                        flex: 10,
                                      ),
                                      Flexible(
                                        flex: 28,
                                        child: Padding(
                                            padding: EdgeInsets.only(),
                                            child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.827,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.030,
                                                child: Align(
                                                  alignment:
                                                      Alignment(0.00, 0.00),
                                                  child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Flexible(
                                                          flex: 15,
                                                          child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(),
                                                              child: LayoutBuilder(
                                                                  builder: (context,
                                                                      constraints) {
                                                                return Words(
                                                                  constraints,
                                                                );
                                                              })),
                                                        ),
                                                        Spacer(
                                                          flex: 5,
                                                        ),
                                                        Flexible(
                                                          flex: 14,
                                                          child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(),
                                                              child: LayoutBuilder(
                                                                  builder: (context,
                                                                      constraints) {
                                                                return Words(
                                                                  constraints,
                                                                );
                                                              })),
                                                        ),
                                                        Spacer(
                                                          flex: 5,
                                                        ),
                                                        Flexible(
                                                          flex: 21,
                                                          child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(),
                                                              child: LayoutBuilder(
                                                                  builder: (context,
                                                                      constraints) {
                                                                return Words(
                                                                  constraints,
                                                                );
                                                              })),
                                                        ),
                                                        Spacer(
                                                          flex: 5,
                                                        ),
                                                        Flexible(
                                                          flex: 17,
                                                          child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(),
                                                              child: LayoutBuilder(
                                                                  builder: (context,
                                                                      constraints) {
                                                                return Words(
                                                                  constraints,
                                                                );
                                                              })),
                                                        ),
                                                        Spacer(
                                                          flex: 5,
                                                        ),
                                                        Flexible(
                                                          flex: 18,
                                                          child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(),
                                                              child: LayoutBuilder(
                                                                  builder: (context,
                                                                      constraints) {
                                                                return Words(
                                                                  constraints,
                                                                );
                                                              })),
                                                        )
                                                      ]),
                                                ))),
                                      ),
                                      Spacer(
                                        flex: 10,
                                      ),
                                      Flexible(
                                        flex: 28,
                                        child: Padding(
                                            padding: EdgeInsets.only(
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.19,
                                              right: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.22,
                                            ),
                                            child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.422,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.030,
                                                child: Align(
                                                  alignment:
                                                      Alignment(0.00, 0.00),
                                                  child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Flexible(
                                                          flex: 28,
                                                          child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(),
                                                              child: LayoutBuilder(
                                                                  builder: (context,
                                                                      constraints) {
                                                                return Words(
                                                                  constraints,
                                                                );
                                                              })),
                                                        ),
                                                        Spacer(
                                                          flex: 9,
                                                        ),
                                                        Flexible(
                                                          flex: 24,
                                                          child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(),
                                                              child: LayoutBuilder(
                                                                  builder: (context,
                                                                      constraints) {
                                                                return Words(
                                                                  constraints,
                                                                );
                                                              })),
                                                        ),
                                                        Spacer(
                                                          flex: 9,
                                                        ),
                                                        Flexible(
                                                          flex: 33,
                                                          child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(),
                                                              child: LayoutBuilder(
                                                                  builder: (context,
                                                                      constraints) {
                                                                return Words(
                                                                  constraints,
                                                                );
                                                              })),
                                                        )
                                                      ]),
                                                ))),
                                      ),
                                    ]),
                              ))),
                    ),
                    Spacer(
                      flex: 20,
                    ),
                    Flexible(
                      flex: 7,
                      child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.09,
                            right: MediaQuery.of(context).size.width * 0.09,
                          ),
                          child: LayoutBuilder(builder: (context, constraints) {
                            return ButtonInactive(
                              constraints,
                            );
                          })),
                    ),
                  ]),
            )),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
