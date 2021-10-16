import 'package:flutter/material.dart';
import '../../view/symbols/navbar_desktop.dart';
import '../../view/symbols/background_desktop.dart';
import '../../view/symbols/cover_text_desktop.dart';
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
                  left: MediaQuery.of(context).size.width * 0.315,
                  right: MediaQuery.of(context).size.width * 0.315,
                  top: MediaQuery.of(context).size.height * 0.114,
                  bottom: MediaQuery.of(context).size.height * 0.624,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return CoverTextDesktop(
                      constraints,
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.351,
                  right: MediaQuery.of(context).size.width * 0.000,
                  top: MediaQuery.of(context).size.height * 0.338,
                  bottom: MediaQuery.of(context).size.height * 0.000,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.650,
                      height: MediaQuery.of(context).size.height * 0.685,
                      child: Align(
                        alignment: Alignment(0.00, 0.00),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                flex: 100,
                                child: Padding(
                                    padding: EdgeInsets.only(),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.650,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.685,
                                        child: Align(
                                          alignment: Alignment(0.00, 0.00),
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  flex: 39,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                        right: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.35,
                                                      ),
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.299,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.262,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xff0068ef),
                                                        ),
                                                      )),
                                                ),
                                                Spacer(
                                                  flex: 6,
                                                ),
                                                Flexible(
                                                  flex: 22,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                        right: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.35,
                                                      ),
                                                      child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.291,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.147,
                                                          child: Align(
                                                            alignment:
                                                                Alignment(
                                                                    0.00, 0.00),
                                                            child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Flexible(
                                                                    flex: 28,
                                                                    child: Padding(
                                                                        padding: EdgeInsets.only(),
                                                                        child: Container(
                                                                            width: MediaQuery.of(context).size.width * 0.291,
                                                                            height: MediaQuery.of(context).size.height * 0.040,
                                                                            child: Align(
                                                                              alignment: Alignment(0.00, 0.00),
                                                                              child: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
                                                                                Flexible(
                                                                                  flex: 21,
                                                                                  child: Padding(
                                                                                      padding: EdgeInsets.only(),
                                                                                      child: LayoutBuilder(builder: (context, constraints) {
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
                                                                                      padding: EdgeInsets.only(),
                                                                                      child: LayoutBuilder(builder: (context, constraints) {
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
                                                                                      padding: EdgeInsets.only(),
                                                                                      child: LayoutBuilder(builder: (context, constraints) {
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
                                                                                      padding: EdgeInsets.only(),
                                                                                      child: LayoutBuilder(builder: (context, constraints) {
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
                                                                            width: MediaQuery.of(context).size.width * 0.291,
                                                                            height: MediaQuery.of(context).size.height * 0.040,
                                                                            child: Align(
                                                                              alignment: Alignment(0.00, 0.00),
                                                                              child: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
                                                                                Flexible(
                                                                                  flex: 15,
                                                                                  child: Padding(
                                                                                      padding: EdgeInsets.only(),
                                                                                      child: LayoutBuilder(builder: (context, constraints) {
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
                                                                                      padding: EdgeInsets.only(),
                                                                                      child: LayoutBuilder(builder: (context, constraints) {
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
                                                                                      padding: EdgeInsets.only(),
                                                                                      child: LayoutBuilder(builder: (context, constraints) {
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
                                                                                      padding: EdgeInsets.only(),
                                                                                      child: LayoutBuilder(builder: (context, constraints) {
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
                                                                                      padding: EdgeInsets.only(),
                                                                                      child: LayoutBuilder(builder: (context, constraints) {
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
                                                                          left: MediaQuery.of(context).size.width *
                                                                              0.07,
                                                                          right:
                                                                              MediaQuery.of(context).size.width * 0.08,
                                                                        ),
                                                                        child: Container(
                                                                            width: MediaQuery.of(context).size.width * 0.148,
                                                                            height: MediaQuery.of(context).size.height * 0.040,
                                                                            child: Align(
                                                                              alignment: Alignment(0.00, 0.00),
                                                                              child: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
                                                                                Flexible(
                                                                                  flex: 28,
                                                                                  child: Padding(
                                                                                      padding: EdgeInsets.only(),
                                                                                      child: LayoutBuilder(builder: (context, constraints) {
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
                                                                                      padding: EdgeInsets.only(),
                                                                                      child: LayoutBuilder(builder: (context, constraints) {
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
                                                                                      padding: EdgeInsets.only(),
                                                                                      child: LayoutBuilder(builder: (context, constraints) {
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
                                                Flexible(
                                                  flex: 72,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                        left: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.43,
                                                      ),
                                                      child: Image.asset(
                                                        'assets/images/0_446.png',
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.223,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.489,
                                                      )),
                                                ),
                                              ]),
                                        ))),
                              ),
                              Flexible(
                                flex: 46,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      bottom:
                                          MediaQuery.of(context).size.height *
                                              0.07,
                                      top: MediaQuery.of(context).size.height *
                                          0.53,
                                    ),
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return ButtonInactive(
                                        constraints,
                                      );
                                    })),
                              )
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
