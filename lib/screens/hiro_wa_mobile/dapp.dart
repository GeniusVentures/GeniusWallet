import 'package:flutter/material.dart';
import '../../view/symbols/navigation_next.dart';
import '../../view/symbols/text_input_with_button.dart';
import '../../view/symbols/mult_choice.dart';
import '../../view/symbols/button_active.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Dapp extends StatefulWidget {
  const Dapp() : super();
  @override
  _Dapp createState() => _Dapp();
}

class _Dapp extends State<Dapp> {
  _Dapp();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Align(
        alignment: Alignment(0.00, 0.05),
        child: Container(
            width: MediaQuery.of(context).size.width * 1.000,
            height: MediaQuery.of(context).size.height * 0.885,
            child: Align(
              alignment: Alignment(0.00, 0.00),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 6,
                      child: Padding(
                          padding: EdgeInsets.only(),
                          child: Container(
                              width: MediaQuery.of(context).size.width * 1.000,
                              height:
                                  MediaQuery.of(context).size.height * 0.046,
                              child: Align(
                                alignment: Alignment(0.00, 0.00),
                                child: Stack(children: [
                                  LayoutBuilder(
                                      builder: (context, constraints) {
                                    return NavigationNext(
                                      constraints,
                                    );
                                  }),
                                  Positioned(
                                    left: MediaQuery.of(context).size.width *
                                        0.164,
                                    right: MediaQuery.of(context).size.width *
                                        0.148,
                                    top: MediaQuery.of(context).size.height *
                                        0.006,
                                    bottom: MediaQuery.of(context).size.height *
                                        0.006,
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.688,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.033,
                                        child: Align(
                                          alignment: Alignment(0.00, 0.00),
                                          child: AutoSizeText(
                                            'Job Information',
                                            style: TextStyle(
                                              fontFamily: 'Prompt',
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.normal,
                                              letterSpacing: 0.0,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        )),
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
                            left: MediaQuery.of(context).size.width * 0.09,
                            right: MediaQuery.of(context).size.width * 0.76,
                          ),
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.157,
                              height:
                                  MediaQuery.of(context).size.height * 0.033,
                              child: Align(
                                alignment: Alignment(0.00, 0.00),
                                child: AutoSizeText(
                                  'Details',
                                  style: TextStyle(
                                    fontFamily: 'Prompt',
                                    fontSize: 18.0,
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
                      flex: 2,
                    ),
                    Flexible(
                      flex: 7,
                      child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.09,
                            right: MediaQuery.of(context).size.width * 0.09,
                          ),
                          child: LayoutBuilder(builder: (context, constraints) {
                            return TextInputWithButton(
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
                            left: MediaQuery.of(context).size.width * 0.09,
                            right: MediaQuery.of(context).size.width * 0.09,
                          ),
                          child: LayoutBuilder(builder: (context, constraints) {
                            return TextInputWithButton(
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
                            left: MediaQuery.of(context).size.width * 0.09,
                            right: MediaQuery.of(context).size.width * 0.09,
                          ),
                          child: LayoutBuilder(builder: (context, constraints) {
                            return MultChoice(
                              constraints,
                            );
                          })),
                    ),
                    Spacer(
                      flex: 2,
                    ),
                    Flexible(
                      flex: 12,
                      child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.09,
                            right: MediaQuery.of(context).size.width * 0.09,
                          ),
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.827,
                              height:
                                  MediaQuery.of(context).size.height * 0.103,
                              child: Align(
                                alignment: Alignment(0.00, 0.00),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        flex: 33,
                                        child: Padding(
                                            padding: EdgeInsets.only(
                                              right: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.05,
                                            ),
                                            child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.776,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.033,
                                                child: Align(
                                                  alignment:
                                                      Alignment(0.00, 0.00),
                                                  child: AutoSizeText(
                                                    'amount to pay per GB',
                                                    style: TextStyle(
                                                      fontFamily: 'Prompt',
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      letterSpacing: 0.0,
                                                      color: Colors.white,
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ))),
                                      ),
                                      Spacer(
                                        flex: 17,
                                      ),
                                      Flexible(
                                        flex: 15,
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
                                                    0.015,
                                                child: Align(
                                                  alignment:
                                                      Alignment(0.00, 0.00),
                                                  child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Flexible(
                                                          flex: 50,
                                                          child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(),
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/26_1893.png',
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.827,
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.007,
                                                              )),
                                                        ),
                                                        Flexible(
                                                          flex: 100,
                                                          child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(
                                                                left: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.35,
                                                                right: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.45,
                                                              ),
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/26_1890.png',
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.032,
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.015,
                                                              )),
                                                        ),
                                                      ]),
                                                ))),
                                      ),
                                      Flexible(
                                        flex: 37,
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
                                                    0.038,
                                                child: Align(
                                                  alignment:
                                                      Alignment(0.00, 0.00),
                                                  child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Flexible(
                                                          flex: 1,
                                                          child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(
                                                                bottom: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.03,
                                                              ),
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/26_1891.png',
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.005,
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.007,
                                                              )),
                                                        ),
                                                        Spacer(
                                                          flex: 41,
                                                        ),
                                                        Flexible(
                                                          flex: 16,
                                                          child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(),
                                                              child: Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.128,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.033,
                                                                  child: Align(
                                                                    alignment:
                                                                        Alignment(
                                                                            0.00,
                                                                            0.00),
                                                                    child:
                                                                        AutoSizeText(
                                                                      '\$0.98',
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Prompt',
                                                                        fontSize:
                                                                            18.0,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontStyle:
                                                                            FontStyle.normal,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                  ))),
                                                        ),
                                                        Flexible(
                                                          flex: 9,
                                                          child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(
                                                                top: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.01,
                                                              ),
                                                              child: Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.067,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.018,
                                                                  child: Align(
                                                                    alignment:
                                                                        Alignment(
                                                                            0.00,
                                                                            0.00),
                                                                    child:
                                                                        AutoSizeText(
                                                                      '\$0.01',
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Prompt',
                                                                        fontSize:
                                                                            10.0,
                                                                        fontWeight:
                                                                            FontWeight.w300,
                                                                        fontStyle:
                                                                            FontStyle.normal,
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
                                                          flex: 91,
                                                        ),
                                                        Flexible(
                                                          flex: 1,
                                                          child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(
                                                                bottom: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.03,
                                                              ),
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/26_1892.png',
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.005,
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.007,
                                                              )),
                                                        ),
                                                        Flexible(
                                                          flex: 9,
                                                          child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(
                                                                top: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.01,
                                                              ),
                                                              child: Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.072,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.018,
                                                                  child: Align(
                                                                    alignment:
                                                                        Alignment(
                                                                            0.00,
                                                                            0.00),
                                                                    child:
                                                                        AutoSizeText(
                                                                      '\$5.00',
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Prompt',
                                                                        fontSize:
                                                                            10.0,
                                                                        fontWeight:
                                                                            FontWeight.w300,
                                                                        fontStyle:
                                                                            FontStyle.normal,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                    ),
                                                                  ))),
                                                        )
                                                      ]),
                                                ))),
                                      ),
                                    ]),
                              ))),
                    ),
                    Spacer(
                      flex: 5,
                    ),
                    Flexible(
                      flex: 35,
                      child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.27,
                            right: MediaQuery.of(context).size.width * 0.26,
                          ),
                          child: Image.asset(
                            'assets/images/0_194.png',
                            width: MediaQuery.of(context).size.width * 0.468,
                            height: MediaQuery.of(context).size.height * 0.305,
                          )),
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
