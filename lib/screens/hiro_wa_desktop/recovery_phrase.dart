import 'package:flutter/material.dart';
import '../../view/symbols/navbar_desktop.dart';
import '../../view/symbols/background_desktop.dart';
import '../../view/symbols/cover_text_desktop.dart';
import '../../view/symbols/navigation_info.dart';
import '../../view/symbols/words.dart';
import '../../view/symbols/button_active.dart';
import '../../view/symbols/alert.dart';
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
        alignment: Alignment(-1.00, -1.00),
        child: Container(
            width: MediaQuery.of(context).size.width * 1.000,
            height: MediaQuery.of(context).size.height * 1.023,
            child: Align(
              alignment: Alignment(0.00, 0.00),
              child: Stack(children: [
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.000,
                  right: MediaQuery.of(context).size.width * 0.000,
                  top: MediaQuery.of(context).size.height * 0.000,
                  bottom: MediaQuery.of(context).size.height * 0.961,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return NavbarDesktop(
                      constraints,
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.001,
                  right: MediaQuery.of(context).size.width * 0.000,
                  top: MediaQuery.of(context).size.height * 0.000,
                  bottom: MediaQuery.of(context).size.height * 0.023,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return BackgroundDesktop(
                      constraints,
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.064,
                  right: MediaQuery.of(context).size.width * 0.000,
                  top: MediaQuery.of(context).size.height * 0.114,
                  bottom: MediaQuery.of(context).size.height * 0.000,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.937,
                      height: MediaQuery.of(context).size.height * 0.909,
                      child: Align(
                        alignment: Alignment(0.00, 0.00),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                flex: 35,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          0.11,
                                    ),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.827,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.311,
                                        child: Align(
                                          alignment: Alignment(0.00, 0.00),
                                          child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Flexible(
                                                  flex: 45,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                        bottom: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.03,
                                                      ),
                                                      child: LayoutBuilder(
                                                          builder: (context,
                                                              constraints) {
                                                        return CoverTextDesktop(
                                                          constraints,
                                                        );
                                                      })),
                                                ),
                                                Flexible(
                                                  flex: 100,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                        bottom: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.22,
                                                        top: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.02,
                                                      ),
                                                      child: LayoutBuilder(
                                                          builder: (context,
                                                              constraints) {
                                                        return NavigationInfo(
                                                          constraints,
                                                        );
                                                      })),
                                                ),
                                                Flexible(
                                                  flex: 7,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                        top: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.27,
                                                      ),
                                                      child: LayoutBuilder(
                                                          builder: (context,
                                                              constraints) {
                                                        return Words(
                                                          constraints,
                                                        );
                                                      })),
                                                ),
                                                Spacer(
                                                  flex: 2,
                                                ),
                                                Flexible(
                                                  flex: 7,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                        top: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.27,
                                                      ),
                                                      child: LayoutBuilder(
                                                          builder: (context,
                                                              constraints) {
                                                        return Words(
                                                          constraints,
                                                        );
                                                      })),
                                                ),
                                                Spacer(
                                                  flex: 2,
                                                ),
                                                Flexible(
                                                  flex: 11,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                        top: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.27,
                                                      ),
                                                      child: LayoutBuilder(
                                                          builder: (context,
                                                              constraints) {
                                                        return Words(
                                                          constraints,
                                                        );
                                                      })),
                                                ),
                                                Spacer(
                                                  flex: 2,
                                                ),
                                                Flexible(
                                                  flex: 8,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                        top: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.27,
                                                      ),
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
                                flex: 2,
                              ),
                              Flexible(
                                flex: 5,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.32,
                                      right: MediaQuery.of(context).size.width *
                                          0.39,
                                    ),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.227,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.040,
                                        child: Align(
                                          alignment: Alignment(0.00, 0.00),
                                          child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  flex: 33,
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.only(),
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
                                                          EdgeInsets.only(),
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
                                                          EdgeInsets.only(),
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
                                flex: 2,
                              ),
                              Flexible(
                                flex: 5,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.31,
                                      right: MediaQuery.of(context).size.width *
                                          0.37,
                                    ),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.257,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.040,
                                        child: Align(
                                          alignment: Alignment(0.00, 0.00),
                                          child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  flex: 33,
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.only(),
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
                                                          EdgeInsets.only(),
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
                                                          EdgeInsets.only(),
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
                                flex: 1,
                              ),
                              Flexible(
                                flex: 54,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.29,
                                    ),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.646,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.489,
                                        child: Align(
                                          alignment: Alignment(0.00, 0.00),
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Flexible(
                                                  flex: 12,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                        right: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.35,
                                                      ),
                                                      child: LayoutBuilder(
                                                          builder: (context,
                                                              constraints) {
                                                        return ButtonActive(
                                                          constraints,
                                                        );
                                                      })),
                                                ),
                                                Flexible(
                                                  flex: 20,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                        right: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.35,
                                                      ),
                                                      child: LayoutBuilder(
                                                          builder: (context,
                                                              constraints) {
                                                        return Alert(
                                                          constraints,
                                                        );
                                                      })),
                                                ),
                                                Flexible(
                                                  flex: 100,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                        left: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.07,
                                                      ),
                                                      child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.574,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.489,
                                                          child: Align(
                                                            alignment:
                                                                Alignment(
                                                                    0.00, 0.00),
                                                            child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Flexible(
                                                                    flex: 9,
                                                                    child: Padding(
                                                                        padding: EdgeInsets.only(
                                                                          right:
                                                                              MediaQuery.of(context).size.width * 0.50,
                                                                        ),
                                                                        child: LayoutBuilder(builder: (context, constraints) {
                                                                          return Words(
                                                                            constraints,
                                                                          );
                                                                        })),
                                                                  ),
                                                                  Spacer(
                                                                    flex: 12,
                                                                  ),
                                                                  Flexible(
                                                                    flex: 9,
                                                                    child: Padding(
                                                                        padding: EdgeInsets.only(
                                                                          left: MediaQuery.of(context).size.width *
                                                                              0.03,
                                                                          right:
                                                                              MediaQuery.of(context).size.width * 0.46,
                                                                        ),
                                                                        child: Container(
                                                                            width: MediaQuery.of(context).size.width * 0.077,
                                                                            height: MediaQuery.of(context).size.height * 0.041,
                                                                            child: Align(
                                                                              alignment: Alignment(0.00, 0.00),
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
                                                                              ),
                                                                            ))),
                                                                  ),
                                                                  Flexible(
                                                                    flex: 9,
                                                                    child: Padding(
                                                                        padding: EdgeInsets.only(
                                                                          left: MediaQuery.of(context).size.width *
                                                                              0.08,
                                                                          right:
                                                                              MediaQuery.of(context).size.width * 0.43,
                                                                        ),
                                                                        child: LayoutBuilder(builder: (context, constraints) {
                                                                          return Words(
                                                                            constraints,
                                                                          );
                                                                        })),
                                                                  ),
                                                                  Flexible(
                                                                    flex: 100,
                                                                    child: Padding(
                                                                        padding: EdgeInsets.only(
                                                                          left: MediaQuery.of(context).size.width *
                                                                              0.35,
                                                                        ),
                                                                        child: Image.asset(
                                                                          'assets/images/0_387.png',
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.223,
                                                                          height:
                                                                              MediaQuery.of(context).size.height * 0.489,
                                                                        )),
                                                                  ),
                                                                ]),
                                                          ))),
                                                ),
                                              ]),
                                        ))),
                              ),
                            ]),
                      )),
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
