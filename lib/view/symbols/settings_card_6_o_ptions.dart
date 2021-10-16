import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class SettingsCard6OPtions extends StatelessWidget {
  final constraints;

  SettingsCard6OPtions(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: constraints.maxWidth * 1.000,
        height: constraints.maxHeight * 1.000,
        decoration: BoxDecoration(
          color: Color(0xff003698),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          border: Border.all(
            color: Color(0x00000000),
          ),
        ),
        child: Align(
          alignment: Alignment(-0.14, 0.00),
          child: Container(
              width: constraints.maxWidth * 0.955,
              height: constraints.maxHeight * 0.963,
              child: Align(
                alignment: Alignment(0.00, 0.00),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 14,
                        child: Padding(
                            padding: EdgeInsets.only(),
                            child: Container(
                                width: constraints.maxWidth * 0.955,
                                height: constraints.maxHeight * 0.130,
                                child: Align(
                                  alignment: Alignment(0.00, 0.00),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          flex: 100,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05,
                                              ),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.903,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.130,
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
                                                            flex: 13,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(),
                                                                child:
                                                                    Container(
                                                                  width: constraints
                                                                          .maxWidth *
                                                                      0.113,
                                                                  height: constraints
                                                                          .maxHeight *
                                                                      0.130,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Color(
                                                                        0x00000000),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(7.0)),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Color(
                                                                          0x00000000),
                                                                    ),
                                                                  ),
                                                                )),
                                                          ),
                                                          Spacer(
                                                            flex: 3,
                                                          ),
                                                          Flexible(
                                                            flex: 86,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(
                                                                  bottom: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.02,
                                                                  top: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.03,
                                                                ),
                                                                child:
                                                                    Container(
                                                                        width: constraints.maxWidth *
                                                                            0.768,
                                                                        height: constraints.maxHeight *
                                                                            0.081,
                                                                        child:
                                                                            Align(
                                                                          alignment: Alignment(
                                                                              0.00,
                                                                              0.00),
                                                                          child:
                                                                              AutoSizeText(
                                                                            'Type something',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Prompt',
                                                                              fontSize: 14.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FontStyle.normal,
                                                                              letterSpacing: 0.0,
                                                                              color: Colors.white,
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                          ),
                                                                        ))),
                                                          )
                                                        ]),
                                                  ))),
                                        ),
                                        Flexible(
                                          flex: 13,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.94,
                                              ),
                                              child: Image.asset(
                                                'assets/images/0_12313.png',
                                                width: constraints.maxWidth *
                                                    0.015,
                                                height: constraints.maxHeight *
                                                    0.017,
                                              )),
                                        ),
                                      ]),
                                ))),
                      ),
                      Spacer(
                        flex: 2,
                      ),
                      Flexible(
                        flex: 1,
                        child: Padding(
                            padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.14,
                            ),
                            child: Image.asset(
                              'assets/images/0_12348.png',
                              width: constraints.maxWidth * 0.819,
                              height: constraints.maxHeight * 0.007,
                            )),
                      ),
                      Spacer(
                        flex: 2,
                      ),
                      Flexible(
                        flex: 14,
                        child: Padding(
                            padding: EdgeInsets.only(),
                            child: Container(
                                width: constraints.maxWidth * 0.955,
                                height: constraints.maxHeight * 0.130,
                                child: Align(
                                  alignment: Alignment(0.00, 0.00),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          flex: 100,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05,
                                              ),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.903,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.130,
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
                                                            flex: 13,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(),
                                                                child:
                                                                    Container(
                                                                  width: constraints
                                                                          .maxWidth *
                                                                      0.113,
                                                                  height: constraints
                                                                          .maxHeight *
                                                                      0.130,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Color(
                                                                        0x00000000),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(7.0)),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Color(
                                                                          0x00000000),
                                                                    ),
                                                                  ),
                                                                )),
                                                          ),
                                                          Spacer(
                                                            flex: 3,
                                                          ),
                                                          Flexible(
                                                            flex: 86,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(
                                                                  bottom: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.02,
                                                                  top: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.03,
                                                                ),
                                                                child:
                                                                    Container(
                                                                        width: constraints.maxWidth *
                                                                            0.768,
                                                                        height: constraints.maxHeight *
                                                                            0.081,
                                                                        child:
                                                                            Align(
                                                                          alignment: Alignment(
                                                                              0.00,
                                                                              0.00),
                                                                          child:
                                                                              AutoSizeText(
                                                                            'Type something',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Prompt',
                                                                              fontSize: 14.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FontStyle.normal,
                                                                              letterSpacing: 0.0,
                                                                              color: Colors.white,
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                          ),
                                                                        ))),
                                                          )
                                                        ]),
                                                  ))),
                                        ),
                                        Flexible(
                                          flex: 13,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.94,
                                              ),
                                              child: Image.asset(
                                                'assets/images/0_12319.png',
                                                width: constraints.maxWidth *
                                                    0.015,
                                                height: constraints.maxHeight *
                                                    0.017,
                                              )),
                                        ),
                                      ]),
                                ))),
                      ),
                      Spacer(
                        flex: 2,
                      ),
                      Flexible(
                        flex: 1,
                        child: Padding(
                            padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.14,
                            ),
                            child: Image.asset(
                              'assets/images/0_12349.png',
                              width: constraints.maxWidth * 0.819,
                              height: constraints.maxHeight * 0.007,
                            )),
                      ),
                      Spacer(
                        flex: 2,
                      ),
                      Flexible(
                        flex: 14,
                        child: Padding(
                            padding: EdgeInsets.only(),
                            child: Container(
                                width: constraints.maxWidth * 0.955,
                                height: constraints.maxHeight * 0.130,
                                child: Align(
                                  alignment: Alignment(0.00, 0.00),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          flex: 100,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05,
                                              ),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.903,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.130,
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
                                                            flex: 13,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(),
                                                                child:
                                                                    Container(
                                                                  width: constraints
                                                                          .maxWidth *
                                                                      0.113,
                                                                  height: constraints
                                                                          .maxHeight *
                                                                      0.130,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Color(
                                                                        0x00000000),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(7.0)),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Color(
                                                                          0x00000000),
                                                                    ),
                                                                  ),
                                                                )),
                                                          ),
                                                          Spacer(
                                                            flex: 3,
                                                          ),
                                                          Flexible(
                                                            flex: 86,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(
                                                                  bottom: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.02,
                                                                  top: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.03,
                                                                ),
                                                                child:
                                                                    Container(
                                                                        width: constraints.maxWidth *
                                                                            0.768,
                                                                        height: constraints.maxHeight *
                                                                            0.081,
                                                                        child:
                                                                            Align(
                                                                          alignment: Alignment(
                                                                              0.00,
                                                                              0.00),
                                                                          child:
                                                                              AutoSizeText(
                                                                            'Type something',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Prompt',
                                                                              fontSize: 14.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FontStyle.normal,
                                                                              letterSpacing: 0.0,
                                                                              color: Colors.white,
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                          ),
                                                                        ))),
                                                          )
                                                        ]),
                                                  ))),
                                        ),
                                        Flexible(
                                          flex: 13,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.94,
                                              ),
                                              child: Image.asset(
                                                'assets/images/0_12325.png',
                                                width: constraints.maxWidth *
                                                    0.015,
                                                height: constraints.maxHeight *
                                                    0.017,
                                              )),
                                        ),
                                      ]),
                                ))),
                      ),
                      Spacer(
                        flex: 2,
                      ),
                      Flexible(
                        flex: 1,
                        child: Padding(
                            padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.14,
                            ),
                            child: Image.asset(
                              'assets/images/0_12350.png',
                              width: constraints.maxWidth * 0.819,
                              height: constraints.maxHeight * 0.007,
                            )),
                      ),
                      Spacer(
                        flex: 2,
                      ),
                      Flexible(
                        flex: 14,
                        child: Padding(
                            padding: EdgeInsets.only(),
                            child: Container(
                                width: constraints.maxWidth * 0.955,
                                height: constraints.maxHeight * 0.130,
                                child: Align(
                                  alignment: Alignment(0.00, 0.00),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          flex: 100,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05,
                                              ),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.903,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.130,
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
                                                            flex: 13,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(),
                                                                child:
                                                                    Container(
                                                                  width: constraints
                                                                          .maxWidth *
                                                                      0.113,
                                                                  height: constraints
                                                                          .maxHeight *
                                                                      0.130,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Color(
                                                                        0x00000000),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(7.0)),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Color(
                                                                          0x00000000),
                                                                    ),
                                                                  ),
                                                                )),
                                                          ),
                                                          Spacer(
                                                            flex: 3,
                                                          ),
                                                          Flexible(
                                                            flex: 86,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(
                                                                  bottom: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.02,
                                                                  top: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.03,
                                                                ),
                                                                child:
                                                                    Container(
                                                                        width: constraints.maxWidth *
                                                                            0.768,
                                                                        height: constraints.maxHeight *
                                                                            0.081,
                                                                        child:
                                                                            Align(
                                                                          alignment: Alignment(
                                                                              0.00,
                                                                              0.00),
                                                                          child:
                                                                              AutoSizeText(
                                                                            'Type something',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Prompt',
                                                                              fontSize: 14.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FontStyle.normal,
                                                                              letterSpacing: 0.0,
                                                                              color: Colors.white,
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                          ),
                                                                        ))),
                                                          )
                                                        ]),
                                                  ))),
                                        ),
                                        Flexible(
                                          flex: 13,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.94,
                                              ),
                                              child: Image.asset(
                                                'assets/images/0_12331.png',
                                                width: constraints.maxWidth *
                                                    0.015,
                                                height: constraints.maxHeight *
                                                    0.017,
                                              )),
                                        ),
                                      ]),
                                ))),
                      ),
                      Spacer(
                        flex: 2,
                      ),
                      Flexible(
                        flex: 1,
                        child: Padding(
                            padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.14,
                            ),
                            child: Image.asset(
                              'assets/images/0_12351.png',
                              width: constraints.maxWidth * 0.819,
                              height: constraints.maxHeight * 0.007,
                            )),
                      ),
                      Spacer(
                        flex: 2,
                      ),
                      Flexible(
                        flex: 14,
                        child: Padding(
                            padding: EdgeInsets.only(),
                            child: Container(
                                width: constraints.maxWidth * 0.955,
                                height: constraints.maxHeight * 0.130,
                                child: Align(
                                  alignment: Alignment(0.00, 0.00),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          flex: 100,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05,
                                              ),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.903,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.130,
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
                                                            flex: 13,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(),
                                                                child:
                                                                    Container(
                                                                  width: constraints
                                                                          .maxWidth *
                                                                      0.113,
                                                                  height: constraints
                                                                          .maxHeight *
                                                                      0.130,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Color(
                                                                        0x00000000),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(7.0)),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Color(
                                                                          0x00000000),
                                                                    ),
                                                                  ),
                                                                )),
                                                          ),
                                                          Spacer(
                                                            flex: 3,
                                                          ),
                                                          Flexible(
                                                            flex: 86,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(
                                                                  bottom: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.02,
                                                                  top: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.03,
                                                                ),
                                                                child:
                                                                    Container(
                                                                        width: constraints.maxWidth *
                                                                            0.768,
                                                                        height: constraints.maxHeight *
                                                                            0.081,
                                                                        child:
                                                                            Align(
                                                                          alignment: Alignment(
                                                                              0.00,
                                                                              0.00),
                                                                          child:
                                                                              AutoSizeText(
                                                                            'Type something',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Prompt',
                                                                              fontSize: 14.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FontStyle.normal,
                                                                              letterSpacing: 0.0,
                                                                              color: Colors.white,
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                          ),
                                                                        ))),
                                                          )
                                                        ]),
                                                  ))),
                                        ),
                                        Flexible(
                                          flex: 13,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.94,
                                              ),
                                              child: Image.asset(
                                                'assets/images/0_12337.png',
                                                width: constraints.maxWidth *
                                                    0.015,
                                                height: constraints.maxHeight *
                                                    0.017,
                                              )),
                                        ),
                                      ]),
                                ))),
                      ),
                      Spacer(
                        flex: 2,
                      ),
                      Flexible(
                        flex: 1,
                        child: Padding(
                            padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.14,
                            ),
                            child: Image.asset(
                              'assets/images/0_12352.png',
                              width: constraints.maxWidth * 0.819,
                              height: constraints.maxHeight * 0.007,
                            )),
                      ),
                      Spacer(
                        flex: 2,
                      ),
                      Flexible(
                        flex: 14,
                        child: Padding(
                            padding: EdgeInsets.only(),
                            child: Container(
                                width: constraints.maxWidth * 0.955,
                                height: constraints.maxHeight * 0.130,
                                child: Align(
                                  alignment: Alignment(0.00, 0.00),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          flex: 100,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05,
                                              ),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.903,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.130,
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
                                                            flex: 13,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(),
                                                                child:
                                                                    Container(
                                                                  width: constraints
                                                                          .maxWidth *
                                                                      0.113,
                                                                  height: constraints
                                                                          .maxHeight *
                                                                      0.130,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Color(
                                                                        0x00000000),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(7.0)),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Color(
                                                                          0x00000000),
                                                                    ),
                                                                  ),
                                                                )),
                                                          ),
                                                          Spacer(
                                                            flex: 3,
                                                          ),
                                                          Flexible(
                                                            flex: 86,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(
                                                                  bottom: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.02,
                                                                  top: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.03,
                                                                ),
                                                                child:
                                                                    Container(
                                                                        width: constraints.maxWidth *
                                                                            0.768,
                                                                        height: constraints.maxHeight *
                                                                            0.081,
                                                                        child:
                                                                            Align(
                                                                          alignment: Alignment(
                                                                              0.00,
                                                                              0.00),
                                                                          child:
                                                                              AutoSizeText(
                                                                            'Type something',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Prompt',
                                                                              fontSize: 14.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FontStyle.normal,
                                                                              letterSpacing: 0.0,
                                                                              color: Colors.white,
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                          ),
                                                                        ))),
                                                          )
                                                        ]),
                                                  ))),
                                        ),
                                        Flexible(
                                          flex: 13,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.94,
                                              ),
                                              child: Image.asset(
                                                'assets/images/0_12343.png',
                                                width: constraints.maxWidth *
                                                    0.015,
                                                height: constraints.maxHeight *
                                                    0.017,
                                              )),
                                        ),
                                      ]),
                                ))),
                      ),
                    ]),
              )),
        ));
  }
}
