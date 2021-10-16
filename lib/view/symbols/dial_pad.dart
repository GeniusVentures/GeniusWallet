import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class DialPad extends StatelessWidget {
  final constraints;

  DialPad(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: constraints.maxWidth * 1.002,
        height: constraints.maxHeight * 1.000,
        child: Align(
          alignment: Alignment(0.00, 0.00),
          child: Stack(children: [
            Container(
                width: constraints.maxWidth * 1.002,
                height: constraints.maxHeight * 1.000,
                child: Align(
                  alignment: Alignment(0.00, 0.00),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 18,
                          child: Padding(
                              padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.01,
                              ),
                              child: Container(
                                  width: constraints.maxWidth * 0.982,
                                  height: constraints.maxHeight * 0.176,
                                  child: Align(
                                    alignment: Alignment(0.00, 0.00),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            flex: 6,
                                            child: Padding(
                                                padding: EdgeInsets.only(),
                                                child: Container(
                                                    width:
                                                        constraints.maxWidth *
                                                            0.056,
                                                    height:
                                                        constraints.maxHeight *
                                                            0.176,
                                                    child: Align(
                                                      alignment:
                                                          Alignment(0.00, 0.00),
                                                      child: AutoSizeText(
                                                        '1',
                                                        style: TextStyle(
                                                          fontFamily: 'Prompt',
                                                          fontSize: 36.0,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          letterSpacing: 0.0,
                                                          color: Colors.white,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ))),
                                          ),
                                          Spacer(
                                            flex: 40,
                                          ),
                                          Flexible(
                                            flex: 9,
                                            child: Padding(
                                                padding: EdgeInsets.only(),
                                                child: Container(
                                                    width:
                                                        constraints.maxWidth *
                                                            0.085,
                                                    height:
                                                        constraints.maxHeight *
                                                            0.176,
                                                    child: Align(
                                                      alignment:
                                                          Alignment(0.00, 0.00),
                                                      child: AutoSizeText(
                                                        '2',
                                                        style: TextStyle(
                                                          fontFamily: 'Prompt',
                                                          fontSize: 36.0,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          letterSpacing: 0.0,
                                                          color: Colors.white,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ))),
                                          ),
                                          Spacer(
                                            flex: 38,
                                          ),
                                          Flexible(
                                            flex: 9,
                                            child: Padding(
                                                padding: EdgeInsets.only(),
                                                child: Container(
                                                    width:
                                                        constraints.maxWidth *
                                                            0.085,
                                                    height:
                                                        constraints.maxHeight *
                                                            0.176,
                                                    child: Align(
                                                      alignment:
                                                          Alignment(0.00, 0.00),
                                                      child: AutoSizeText(
                                                        '3',
                                                        style: TextStyle(
                                                          fontFamily: 'Prompt',
                                                          fontSize: 36.0,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          letterSpacing: 0.0,
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
                          flex: 10,
                        ),
                        Flexible(
                          flex: 18,
                          child: Padding(
                              padding: EdgeInsets.only(),
                              child: Container(
                                  width: constraints.maxWidth * 1.002,
                                  height: constraints.maxHeight * 0.176,
                                  child: Align(
                                    alignment: Alignment(0.00, 0.00),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            flex: 10,
                                            child: Padding(
                                                padding: EdgeInsets.only(),
                                                child: Container(
                                                    width:
                                                        constraints.maxWidth *
                                                            0.093,
                                                    height:
                                                        constraints.maxHeight *
                                                            0.176,
                                                    child: Align(
                                                      alignment:
                                                          Alignment(0.00, 0.00),
                                                      child: AutoSizeText(
                                                        '4',
                                                        style: TextStyle(
                                                          fontFamily: 'Prompt',
                                                          fontSize: 36.0,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          letterSpacing: 0.0,
                                                          color: Colors.white,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ))),
                                          ),
                                          Spacer(
                                            flex: 37,
                                          ),
                                          Flexible(
                                            flex: 9,
                                            child: Padding(
                                                padding: EdgeInsets.only(),
                                                child: Container(
                                                    width:
                                                        constraints.maxWidth *
                                                            0.085,
                                                    height:
                                                        constraints.maxHeight *
                                                            0.176,
                                                    child: Align(
                                                      alignment:
                                                          Alignment(0.00, 0.00),
                                                      child: AutoSizeText(
                                                        '5',
                                                        style: TextStyle(
                                                          fontFamily: 'Prompt',
                                                          fontSize: 36.0,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          letterSpacing: 0.0,
                                                          color: Colors.white,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ))),
                                          ),
                                          Spacer(
                                            flex: 37,
                                          ),
                                          Flexible(
                                            flex: 10,
                                            child: Padding(
                                                padding: EdgeInsets.only(),
                                                child: Container(
                                                    width:
                                                        constraints.maxWidth *
                                                            0.093,
                                                    height:
                                                        constraints.maxHeight *
                                                            0.176,
                                                    child: Align(
                                                      alignment:
                                                          Alignment(0.00, 0.00),
                                                      child: AutoSizeText(
                                                        '6',
                                                        style: TextStyle(
                                                          fontFamily: 'Prompt',
                                                          fontSize: 36.0,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          letterSpacing: 0.0,
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
                          flex: 10,
                        ),
                        Flexible(
                          flex: 18,
                          child: Padding(
                              padding: EdgeInsets.only(),
                              child: Container(
                                  width: constraints.maxWidth * 0.998,
                                  height: constraints.maxHeight * 0.176,
                                  child: Align(
                                    alignment: Alignment(0.00, 0.00),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            flex: 9,
                                            child: Padding(
                                                padding: EdgeInsets.only(),
                                                child: Container(
                                                    width:
                                                        constraints.maxWidth *
                                                            0.080,
                                                    height:
                                                        constraints.maxHeight *
                                                            0.176,
                                                    child: Align(
                                                      alignment:
                                                          Alignment(0.00, 0.00),
                                                      child: AutoSizeText(
                                                        '7',
                                                        style: TextStyle(
                                                          fontFamily: 'Prompt',
                                                          fontSize: 36.0,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          letterSpacing: 0.0,
                                                          color: Colors.white,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ))),
                                          ),
                                          Spacer(
                                            flex: 37,
                                          ),
                                          Flexible(
                                            flex: 10,
                                            child: Padding(
                                                padding: EdgeInsets.only(),
                                                child: Container(
                                                    width:
                                                        constraints.maxWidth *
                                                            0.093,
                                                    height:
                                                        constraints.maxHeight *
                                                            0.176,
                                                    child: Align(
                                                      alignment:
                                                          Alignment(0.00, 0.00),
                                                      child: AutoSizeText(
                                                        '8',
                                                        style: TextStyle(
                                                          fontFamily: 'Prompt',
                                                          fontSize: 36.0,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          letterSpacing: 0.0,
                                                          color: Colors.white,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ))),
                                          ),
                                          Spacer(
                                            flex: 37,
                                          ),
                                          Flexible(
                                            flex: 10,
                                            child: Padding(
                                                padding: EdgeInsets.only(),
                                                child: Container(
                                                    width:
                                                        constraints.maxWidth *
                                                            0.093,
                                                    height:
                                                        constraints.maxHeight *
                                                            0.176,
                                                    child: Align(
                                                      alignment:
                                                          Alignment(0.00, 0.00),
                                                      child: AutoSizeText(
                                                        '9',
                                                        style: TextStyle(
                                                          fontFamily: 'Prompt',
                                                          fontSize: 36.0,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          letterSpacing: 0.0,
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
                          flex: 10,
                        ),
                        Flexible(
                          flex: 18,
                          child: Padding(
                              padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.03,
                                right: MediaQuery.of(context).size.width * 0.45,
                              ),
                              child: Container(
                                  width: constraints.maxWidth * 0.519,
                                  height: constraints.maxHeight * 0.176,
                                  child: Align(
                                    alignment: Alignment(0.00, 0.00),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            flex: 6,
                                            child: Padding(
                                                padding: EdgeInsets.only(),
                                                child: Container(
                                                    width:
                                                        constraints.maxWidth *
                                                            0.028,
                                                    height:
                                                        constraints.maxHeight *
                                                            0.176,
                                                    child: Align(
                                                      alignment:
                                                          Alignment(0.00, 0.00),
                                                      child: AutoSizeText(
                                                        '.',
                                                        style: TextStyle(
                                                          fontFamily: 'Prompt',
                                                          fontSize: 36.0,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          letterSpacing: 0.0,
                                                          color: Colors.white,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ))),
                                          ),
                                          Spacer(
                                            flex: 76,
                                          ),
                                          Flexible(
                                            flex: 20,
                                            child: Padding(
                                                padding: EdgeInsets.only(),
                                                child: Container(
                                                    width:
                                                        constraints.maxWidth *
                                                            0.101,
                                                    height:
                                                        constraints.maxHeight *
                                                            0.176,
                                                    child: Align(
                                                      alignment:
                                                          Alignment(0.00, 0.00),
                                                      child: AutoSizeText(
                                                        '0',
                                                        style: TextStyle(
                                                          fontFamily: 'Prompt',
                                                          fontSize: 36.0,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          letterSpacing: 0.0,
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
            Positioned(
              left: constraints.maxWidth * 0.874,
              right: constraints.maxWidth * 0.000,
              top: constraints.maxHeight * 0.889,
              bottom: constraints.maxHeight * 0.042,
              child: Image.asset(
                'assets/images/0_12496.png',
                width: constraints.maxWidth * 0.128,
                height: constraints.maxHeight * 0.069,
              ),
            ),
          ]),
        ));
  }
}
