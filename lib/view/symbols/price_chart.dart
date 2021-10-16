import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class PriceChart extends StatelessWidget {
  final constraints;

  PriceChart(
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
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          border: Border.all(
            color: Color(0x00000000),
          ),
        ),
        child: Align(
          alignment: Alignment(-0.02, -0.30),
          child: Container(
              width: constraints.maxWidth * 0.925,
              height: constraints.maxHeight * 0.815,
              child: Align(
                alignment: Alignment(0.00, 0.00),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 11,
                        child: Padding(
                            padding: EdgeInsets.only(),
                            child: Container(
                                width: constraints.maxWidth * 0.915,
                                height: constraints.maxHeight * 0.083,
                                child: Align(
                                  alignment: Alignment(0.00, 0.00),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          flex: 26,
                                          child: Padding(
                                              padding: EdgeInsets.only(),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.237,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.083,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: AutoSizeText(
                                                      'Ethereum Chart',
                                                      style: TextStyle(
                                                        fontFamily: 'Prompt',
                                                        fontSize: 20.0,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        letterSpacing:
                                                            0.30000001192092896,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ))),
                                        ),
                                        Spacer(
                                          flex: 48,
                                        ),
                                        Flexible(
                                          flex: 3,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.03,
                                              ),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.025,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.050,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: AutoSizeText(
                                                      '1m',
                                                      style: TextStyle(
                                                        fontFamily: 'Prompt',
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        letterSpacing:
                                                            0.30000001192092896,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
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
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.03,
                                              ),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.057,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.055,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xff004abb),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                14.0)),
                                                    border: Border.all(
                                                      color: Color(0xff003698),
                                                    ),
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        Alignment(-0.05, -0.57),
                                                    child: Container(
                                                        width: constraints
                                                                .maxWidth *
                                                            0.028,
                                                        height: constraints
                                                                .maxHeight *
                                                            0.050,
                                                        child: Align(
                                                          alignment: Alignment(
                                                              0.00, 0.00),
                                                          child: AutoSizeText(
                                                            '3m',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Prompt',
                                                              fontSize: 12.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .normal,
                                                              letterSpacing:
                                                                  0.30000001192092896,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        )),
                                                  ))),
                                        ),
                                        Spacer(
                                          flex: 2,
                                        ),
                                        Flexible(
                                          flex: 4,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.03,
                                              ),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.028,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.050,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: AutoSizeText(
                                                      '6m',
                                                      style: TextStyle(
                                                        fontFamily: 'Prompt',
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        letterSpacing:
                                                            0.30000001192092896,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ))),
                                        ),
                                        Spacer(
                                          flex: 4,
                                        ),
                                        Flexible(
                                          flex: 3,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.03,
                                              ),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.018,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.050,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: AutoSizeText(
                                                      '1y',
                                                      style: TextStyle(
                                                        fontFamily: 'Prompt',
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        letterSpacing:
                                                            0.30000001192092896,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ))),
                                        ),
                                        Spacer(
                                          flex: 4,
                                        ),
                                        Flexible(
                                          flex: 3,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.03,
                                              ),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.025,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.050,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: AutoSizeText(
                                                      'All',
                                                      style: TextStyle(
                                                        fontFamily: 'Prompt',
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        letterSpacing:
                                                            0.30000001192092896,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ))),
                                        )
                                      ]),
                                ))),
                      ),
                      Spacer(
                        flex: 14,
                      ),
                      Flexible(
                        flex: 5,
                        child: Padding(
                            padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.01,
                            ),
                            child: Container(
                                width: constraints.maxWidth * 0.911,
                                height: constraints.maxHeight * 0.033,
                                child: Align(
                                  alignment: Alignment(0.00, 0.00),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          flex: 7,
                                          child: Padding(
                                              padding: EdgeInsets.only(),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.060,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.033,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: AutoSizeText(
                                                      '20k',
                                                      style: TextStyle(
                                                        fontFamily: 'Prompt',
                                                        fontSize: 10.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        letterSpacing: 0.25,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ))),
                                        ),
                                        Spacer(
                                          flex: 3,
                                        ),
                                        Flexible(
                                          flex: 91,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.02,
                                              ),
                                              child: Container(
                                                width: constraints.maxWidth *
                                                    0.825,
                                                height: constraints.maxHeight *
                                                    0.003,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                ),
                                              )),
                                        )
                                      ]),
                                ))),
                      ),
                      Spacer(
                        flex: 10,
                      ),
                      Flexible(
                        flex: 42,
                        child: Padding(
                            padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.01,
                            ),
                            child: Container(
                                width: constraints.maxWidth * 0.911,
                                height: constraints.maxHeight * 0.342,
                                child: Align(
                                  alignment: Alignment(0.00, 0.00),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Flexible(
                                          flex: 91,
                                          child: Padding(
                                              padding: EdgeInsets.only(),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.825,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.342,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: Stack(children: [
                                                      Positioned(
                                                        left: constraints
                                                                .maxWidth *
                                                            0.005,
                                                        right: constraints
                                                                .maxWidth *
                                                            0.000,
                                                        top: constraints
                                                                .maxHeight *
                                                            0.000,
                                                        bottom: constraints
                                                                .maxHeight *
                                                            0.000,
                                                        child: Image.asset(
                                                          'assets/images/0_12639.png',
                                                          width: constraints
                                                                  .maxWidth *
                                                              0.821,
                                                          height: constraints
                                                                  .maxHeight *
                                                              0.342,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        left: constraints
                                                                .maxWidth *
                                                            0.000,
                                                        right: constraints
                                                                .maxWidth *
                                                            0.000,
                                                        top: constraints
                                                                .maxHeight *
                                                            0.033,
                                                        bottom: constraints
                                                                .maxHeight *
                                                            0.306,
                                                        child: Container(
                                                          width: constraints
                                                                  .maxWidth *
                                                              0.825,
                                                          height: constraints
                                                                  .maxHeight *
                                                              0.003,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ]),
                                                  ))),
                                        ),
                                        Flexible(
                                          flex: 7,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.30,
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.01,
                                              ),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.060,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.033,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: AutoSizeText(
                                                      '15k',
                                                      style: TextStyle(
                                                        fontFamily: 'Prompt',
                                                        fontSize: 10.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        letterSpacing: 0.25,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ))),
                                        ),
                                        Flexible(
                                          flex: 7,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.18,
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.13,
                                              ),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.060,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.033,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: AutoSizeText(
                                                      '10k',
                                                      style: TextStyle(
                                                        fontFamily: 'Prompt',
                                                        fontSize: 10.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        letterSpacing: 0.25,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ))),
                                        ),
                                        Spacer(
                                          flex: 3,
                                        ),
                                        Flexible(
                                          flex: 91,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.19,
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.15,
                                              ),
                                              child: Container(
                                                width: constraints.maxWidth *
                                                    0.825,
                                                height: constraints.maxHeight *
                                                    0.003,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                ),
                                              )),
                                        ),
                                        Flexible(
                                          flex: 7,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.06,
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.25,
                                              ),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.060,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.033,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: AutoSizeText(
                                                      '5k',
                                                      style: TextStyle(
                                                        fontFamily: 'Prompt',
                                                        fontSize: 10.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        letterSpacing: 0.25,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ))),
                                        ),
                                        Spacer(
                                          flex: 3,
                                        ),
                                        Flexible(
                                          flex: 91,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.07,
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.27,
                                              ),
                                              child: Container(
                                                width: constraints.maxWidth *
                                                    0.825,
                                                height: constraints.maxHeight *
                                                    0.003,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                ),
                                              )),
                                        )
                                      ]),
                                ))),
                      ),
                      Spacer(
                        flex: 4,
                      ),
                      Flexible(
                        flex: 5,
                        child: Padding(
                            padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.01,
                            ),
                            child: Container(
                                width: constraints.maxWidth * 0.911,
                                height: constraints.maxHeight * 0.036,
                                child: Align(
                                  alignment: Alignment(0.00, 0.00),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          flex: 7,
                                          child: Padding(
                                              padding: EdgeInsets.only(),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.060,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.033,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: AutoSizeText(
                                                      '0k',
                                                      style: TextStyle(
                                                        fontFamily: 'Prompt',
                                                        fontSize: 10.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        letterSpacing: 0.25,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ))),
                                        ),
                                        Spacer(
                                          flex: 3,
                                        ),
                                        Flexible(
                                          flex: 91,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.02,
                                              ),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.825,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.016,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Flexible(
                                                            flex: 20,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(),
                                                                child:
                                                                    Container(
                                                                  width: constraints
                                                                          .maxWidth *
                                                                      0.825,
                                                                  height: constraints
                                                                          .maxHeight *
                                                                      0.003,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                )),
                                                          ),
                                                          Flexible(
                                                            flex: 81,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(
                                                                  left: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.04,
                                                                  right: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.01,
                                                                ),
                                                                child:
                                                                    Container(
                                                                        width: constraints.maxWidth *
                                                                            0.778,
                                                                        height: constraints.maxHeight *
                                                                            0.013,
                                                                        child:
                                                                            Align(
                                                                          alignment: Alignment(
                                                                              0.00,
                                                                              0.00),
                                                                          child: Row(
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Flexible(
                                                                                  flex: 1,
                                                                                  child: Padding(
                                                                                      padding: EdgeInsets.only(),
                                                                                      child: Container(
                                                                                        width: constraints.maxWidth * 0.002,
                                                                                        height: constraints.maxHeight * 0.013,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.white,
                                                                                        ),
                                                                                      )),
                                                                                ),
                                                                                Spacer(
                                                                                  flex: 20,
                                                                                ),
                                                                                Flexible(
                                                                                  flex: 1,
                                                                                  child: Padding(
                                                                                      padding: EdgeInsets.only(),
                                                                                      child: Container(
                                                                                        width: constraints.maxWidth * 0.002,
                                                                                        height: constraints.maxHeight * 0.013,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.white,
                                                                                        ),
                                                                                      )),
                                                                                ),
                                                                                Spacer(
                                                                                  flex: 20,
                                                                                ),
                                                                                Flexible(
                                                                                  flex: 1,
                                                                                  child: Padding(
                                                                                      padding: EdgeInsets.only(),
                                                                                      child: Container(
                                                                                        width: constraints.maxWidth * 0.002,
                                                                                        height: constraints.maxHeight * 0.013,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.white,
                                                                                        ),
                                                                                      )),
                                                                                ),
                                                                                Spacer(
                                                                                  flex: 20,
                                                                                ),
                                                                                Flexible(
                                                                                  flex: 1,
                                                                                  child: Padding(
                                                                                      padding: EdgeInsets.only(),
                                                                                      child: Container(
                                                                                        width: constraints.maxWidth * 0.002,
                                                                                        height: constraints.maxHeight * 0.013,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.white,
                                                                                        ),
                                                                                      )),
                                                                                ),
                                                                                Spacer(
                                                                                  flex: 20,
                                                                                ),
                                                                                Flexible(
                                                                                  flex: 1,
                                                                                  child: Padding(
                                                                                      padding: EdgeInsets.only(),
                                                                                      child: Container(
                                                                                        width: constraints.maxWidth * 0.002,
                                                                                        height: constraints.maxHeight * 0.013,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.white,
                                                                                        ),
                                                                                      )),
                                                                                ),
                                                                                Spacer(
                                                                                  flex: 20,
                                                                                ),
                                                                                Flexible(
                                                                                  flex: 1,
                                                                                  child: Padding(
                                                                                      padding: EdgeInsets.only(),
                                                                                      child: Container(
                                                                                        width: constraints.maxWidth * 0.002,
                                                                                        height: constraints.maxHeight * 0.013,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.white,
                                                                                        ),
                                                                                      )),
                                                                                )
                                                                              ]),
                                                                        ))),
                                                          ),
                                                        ]),
                                                  ))),
                                        )
                                      ]),
                                ))),
                      ),
                      Spacer(
                        flex: 9,
                      ),
                      Flexible(
                        flex: 5,
                        child: Padding(
                            padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.10,
                            ),
                            child: Container(
                                width: constraints.maxWidth * 0.825,
                                height: constraints.maxHeight * 0.033,
                                child: Align(
                                  alignment: Alignment(0.00, 0.00),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          flex: 8,
                                          child: Padding(
                                              padding: EdgeInsets.only(),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.060,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.033,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: AutoSizeText(
                                                      '23 oct',
                                                      style: TextStyle(
                                                        fontFamily: 'Prompt',
                                                        fontSize: 10.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        letterSpacing: 0.25,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ))),
                                        ),
                                        Spacer(
                                          flex: 12,
                                        ),
                                        Flexible(
                                          flex: 8,
                                          child: Padding(
                                              padding: EdgeInsets.only(),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.060,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.033,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: AutoSizeText(
                                                      '6 nov',
                                                      style: TextStyle(
                                                        fontFamily: 'Prompt',
                                                        fontSize: 10.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        letterSpacing: 0.25,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ))),
                                        ),
                                        Spacer(
                                          flex: 12,
                                        ),
                                        Flexible(
                                          flex: 8,
                                          child: Padding(
                                              padding: EdgeInsets.only(),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.060,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.033,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: AutoSizeText(
                                                      '20 nov',
                                                      style: TextStyle(
                                                        fontFamily: 'Prompt',
                                                        fontSize: 10.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        letterSpacing: 0.25,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ))),
                                        ),
                                        Spacer(
                                          flex: 12,
                                        ),
                                        Flexible(
                                          flex: 8,
                                          child: Padding(
                                              padding: EdgeInsets.only(),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.060,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.033,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: AutoSizeText(
                                                      '4 dec',
                                                      style: TextStyle(
                                                        fontFamily: 'Prompt',
                                                        fontSize: 10.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        letterSpacing: 0.25,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ))),
                                        ),
                                        Spacer(
                                          flex: 12,
                                        ),
                                        Flexible(
                                          flex: 8,
                                          child: Padding(
                                              padding: EdgeInsets.only(),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.060,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.033,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: AutoSizeText(
                                                      '18 dec',
                                                      style: TextStyle(
                                                        fontFamily: 'Prompt',
                                                        fontSize: 10.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        letterSpacing: 0.25,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ))),
                                        ),
                                        Spacer(
                                          flex: 12,
                                        ),
                                        Flexible(
                                          flex: 8,
                                          child: Padding(
                                              padding: EdgeInsets.only(),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.060,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.033,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: AutoSizeText(
                                                      '1 jan',
                                                      style: TextStyle(
                                                        fontFamily: 'Prompt',
                                                        fontSize: 10.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        letterSpacing: 0.25,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ))),
                                        )
                                      ]),
                                ))),
                      ),
                    ]),
              )),
        ));
  }
}
