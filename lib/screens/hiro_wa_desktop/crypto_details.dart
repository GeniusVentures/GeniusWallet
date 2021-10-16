import 'package:flutter/material.dart';
import '../../view/symbols/navbar_desktop.dart';
import '../../view/symbols/background_desktop.dart';
import '../../view/symbols/contracts.dart';
import '../../view/symbols/cover_crypto_desktop.dart';
import '../../view/symbols/button_active.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CryptoDetails extends StatefulWidget {
  const CryptoDetails() : super();
  @override
  _CryptoDetails createState() => _CryptoDetails();
}

class _CryptoDetails extends State<CryptoDetails> {
  _CryptoDetails();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Align(
        alignment: Alignment(0.00, 0.00),
        child: Container(
            width: MediaQuery.of(context).size.width * 1.000,
            height: MediaQuery.of(context).size.height * 1.000,
            child: Align(
              alignment: Alignment(0.00, 0.00),
              child: Stack(children: [
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.000,
                  right: MediaQuery.of(context).size.width * 0.000,
                  top: MediaQuery.of(context).size.height * 0.000,
                  bottom: MediaQuery.of(context).size.height * 0.938,
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
                  bottom: MediaQuery.of(context).size.height * 0.000,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return BackgroundDesktop(
                      constraints,
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.180,
                  right: MediaQuery.of(context).size.width * 0.128,
                  top: MediaQuery.of(context).size.height * 0.114,
                  bottom: MediaQuery.of(context).size.height * 0.152,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.692,
                      height: MediaQuery.of(context).size.height * 0.734,
                      child: Align(
                        alignment: Alignment(0.00, 0.00),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                flex: 43,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height *
                                          0.04,
                                    ),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.292,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.696,
                                        child: Align(
                                          alignment: Alignment(0.00, 0.00),
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  flex: 6,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                        right: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.23,
                                                      ),
                                                      child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.064,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.035,
                                                          child: Align(
                                                            alignment:
                                                                Alignment(
                                                                    0.00, 0.00),
                                                            child: AutoSizeText(
                                                              'Yesterday',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Prompt',
                                                                fontSize: 25.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .normal,
                                                                letterSpacing:
                                                                    0.0,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                            ),
                                                          ))),
                                                ),
                                                Spacer(
                                                  flex: 4,
                                                ),
                                                Flexible(
                                                  flex: 92,
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.only(),
                                                      child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.292,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.636,
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
                                                                    flex: 12,
                                                                    child: Padding(
                                                                        padding: EdgeInsets.only(),
                                                                        child: LayoutBuilder(builder: (context, constraints) {
                                                                          return Contracts(
                                                                            constraints,
                                                                          );
                                                                        })),
                                                                  ),
                                                                  Spacer(
                                                                    flex: 4,
                                                                  ),
                                                                  Flexible(
                                                                    flex: 12,
                                                                    child: Padding(
                                                                        padding: EdgeInsets.only(),
                                                                        child: LayoutBuilder(builder: (context, constraints) {
                                                                          return Contracts(
                                                                            constraints,
                                                                          );
                                                                        })),
                                                                  ),
                                                                  Spacer(
                                                                    flex: 4,
                                                                  ),
                                                                  Flexible(
                                                                    flex: 12,
                                                                    child: Padding(
                                                                        padding: EdgeInsets.only(),
                                                                        child: LayoutBuilder(builder: (context, constraints) {
                                                                          return Contracts(
                                                                            constraints,
                                                                          );
                                                                        })),
                                                                  ),
                                                                  Spacer(
                                                                    flex: 4,
                                                                  ),
                                                                  Flexible(
                                                                    flex: 12,
                                                                    child: Padding(
                                                                        padding: EdgeInsets.only(),
                                                                        child: LayoutBuilder(builder: (context, constraints) {
                                                                          return Contracts(
                                                                            constraints,
                                                                          );
                                                                        })),
                                                                  ),
                                                                  Spacer(
                                                                    flex: 4,
                                                                  ),
                                                                  Flexible(
                                                                    flex: 12,
                                                                    child: Padding(
                                                                        padding: EdgeInsets.only(),
                                                                        child: LayoutBuilder(builder: (context, constraints) {
                                                                          return Contracts(
                                                                            constraints,
                                                                          );
                                                                        })),
                                                                  ),
                                                                  Spacer(
                                                                    flex: 4,
                                                                  ),
                                                                  Flexible(
                                                                    flex: 6,
                                                                    child: Padding(
                                                                        padding: EdgeInsets.only(
                                                                          right:
                                                                              MediaQuery.of(context).size.width * 0.22,
                                                                        ),
                                                                        child: Container(
                                                                            width: MediaQuery.of(context).size.width * 0.067,
                                                                            height: MediaQuery.of(context).size.height * 0.035,
                                                                            child: Align(
                                                                              alignment: Alignment(0.00, 0.00),
                                                                              child: AutoSizeText(
                                                                                'Past Week',
                                                                                style: TextStyle(
                                                                                  fontFamily: 'Prompt',
                                                                                  fontSize: 25.0,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  fontStyle: FontStyle.normal,
                                                                                  letterSpacing: 0.0,
                                                                                  color: Colors.white,
                                                                                ),
                                                                                textAlign: TextAlign.left,
                                                                              ),
                                                                            ))),
                                                                  ),
                                                                  Spacer(
                                                                    flex: 5,
                                                                  ),
                                                                  Flexible(
                                                                    flex: 12,
                                                                    child: Padding(
                                                                        padding: EdgeInsets.only(),
                                                                        child: LayoutBuilder(builder: (context, constraints) {
                                                                          return Contracts(
                                                                            constraints,
                                                                          );
                                                                        })),
                                                                  ),
                                                                ]),
                                                          ))),
                                                ),
                                              ]),
                                        ))),
                              ),
                              Spacer(
                                flex: 8,
                              ),
                              Flexible(
                                flex: 51,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      bottom:
                                          MediaQuery.of(context).size.height *
                                              0.08,
                                    ),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.352,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.658,
                                        child: Align(
                                          alignment: Alignment(0.00, 0.00),
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  flex: 71,
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.only(),
                                                      child: LayoutBuilder(
                                                          builder: (context,
                                                              constraints) {
                                                        return CoverCryptoDesktop(
                                                          constraints,
                                                        );
                                                      })),
                                                ),
                                                Spacer(
                                                  flex: 11,
                                                ),
                                                Flexible(
                                                  flex: 9,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                        left: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.04,
                                                        right: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.04,
                                                      ),
                                                      child: LayoutBuilder(
                                                          builder: (context,
                                                              constraints) {
                                                        return ButtonActive(
                                                          constraints,
                                                        );
                                                      })),
                                                ),
                                                Spacer(
                                                  flex: 3,
                                                ),
                                                Flexible(
                                                  flex: 9,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                        left: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.04,
                                                        right: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.04,
                                                      ),
                                                      child: LayoutBuilder(
                                                          builder: (context,
                                                              constraints) {
                                                        return ButtonActive(
                                                          constraints,
                                                        );
                                                      })),
                                                ),
                                              ]),
                                        ))),
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
