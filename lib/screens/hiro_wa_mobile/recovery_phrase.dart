import 'package:flutter/material.dart';
import '../../view/symbols/cover_text.dart';
import '../../view/symbols/navigation_info.dart';
import '../../view/symbols/words.dart';
import '../../view/symbols/alert.dart';
import '../../view/symbols/button_active.dart';
import 'package:auto_size_text/auto_size_text.dart';

class RecoveryPhrase extends StatefulWidget {
  const RecoveryPhrase() : super();
  @override
  _RecoveryPhrase createState() => _RecoveryPhrase();
}

class _RecoveryPhrase extends State<RecoveryPhrase> {
  _RecoveryPhrase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Align(
        alignment: Alignment(1.00, -0.09),
        child: Container(
            width: MediaQuery.of(context).size.width * 1.001,
            height: MediaQuery.of(context).size.height * 0.900,
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
                              width: MediaQuery.of(context).size.width * 1.001,
                              height:
                                  MediaQuery.of(context).size.height * 0.281,
                              child: Align(
                                alignment: Alignment(0.00, 0.00),
                                child: Stack(children: [
                                  Positioned(
                                    left: MediaQuery.of(context).size.width *
                                        0.001,
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
                                        0.001,
                                    top: MediaQuery.of(context).size.height *
                                        0.015,
                                    bottom: MediaQuery.of(context).size.height *
                                        0.220,
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return NavigationInfo(
                                        constraints,
                                      );
                                    }),
                                  ),
                                ]),
                              ))),
                    ),
                    Spacer(
                      flex: 9,
                    ),
                    Flexible(
                      flex: 17,
                      child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.09,
                            right: MediaQuery.of(context).size.width * 0.09,
                          ),
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.819,
                              height:
                                  MediaQuery.of(context).size.height * 0.148,
                              child: Align(
                                alignment: Alignment(0.00, 0.00),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        flex: 20,
                                        child: Padding(
                                            padding: EdgeInsets.only(),
                                            child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.819,
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
                                                          flex: 4,
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
                                                        ),
                                                        Spacer(
                                                          flex: 4,
                                                        ),
                                                        Flexible(
                                                          flex: 30,
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
                                                          flex: 4,
                                                        ),
                                                        Flexible(
                                                          flex: 22,
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
                                        flex: 7,
                                      ),
                                      Flexible(
                                        flex: 20,
                                        child: Padding(
                                            padding: EdgeInsets.only(
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.09,
                                              right: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.09,
                                            ),
                                            child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.645,
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
                                                          flex: 34,
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
                                        flex: 7,
                                      ),
                                      Flexible(
                                        flex: 20,
                                        child: Padding(
                                            padding: EdgeInsets.only(
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04,
                                              right: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04,
                                            ),
                                            child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.731,
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
                                                        ),
                                                        Spacer(
                                                          flex: 5,
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
                                                          flex: 5,
                                                        ),
                                                        Flexible(
                                                          flex: 36,
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
                                        flex: 7,
                                      ),
                                      Flexible(
                                        flex: 20,
                                        child: Padding(
                                            padding: EdgeInsets.only(
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.20,
                                              right: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.20,
                                            ),
                                            child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.419,
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
                                                          flex: 48,
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
                                                          flex: 8,
                                                        ),
                                                        Flexible(
                                                          flex: 46,
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
                      flex: 6,
                    ),
                    Flexible(
                      flex: 4,
                      child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.45,
                            right: MediaQuery.of(context).size.width * 0.45,
                          ),
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.109,
                              height:
                                  MediaQuery.of(context).size.height * 0.030,
                              child: Align(
                                alignment: Alignment(0.00, 0.00),
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
                                ),
                              ))),
                    ),
                    Spacer(
                      flex: 19,
                    ),
                    Flexible(
                      flex: 8,
                      child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.09,
                            right: MediaQuery.of(context).size.width * 0.08,
                          ),
                          child: LayoutBuilder(builder: (context, constraints) {
                            return Alert(
                              constraints,
                            );
                          })),
                    ),
                    Spacer(
                      flex: 3,
                    ),
                    Flexible(
                      flex: 7,
                      child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.09,
                            right: MediaQuery.of(context).size.width * 0.09,
                          ),
                          child: LayoutBuilder(builder: (context, constraints) {
                            return ButtonActive(
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
