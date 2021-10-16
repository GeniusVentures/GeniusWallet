import 'package:flutter/material.dart';
import './transactions.dart';
import './button_active.dart';
import 'package:auto_size_text/auto_size_text.dart';

class TransactionHistory extends StatelessWidget {
  final constraints;

  TransactionHistory(
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
          alignment: Alignment(-0.03, 0.12),
          child: Container(
              width: constraints.maxWidth * 0.882,
              height: constraints.maxHeight * 0.887,
              child: Align(
                alignment: Alignment(0.00, 0.00),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 7,
                        child: Padding(
                            padding: EdgeInsets.only(),
                            child: Container(
                                width: constraints.maxWidth * 0.880,
                                height: constraints.maxHeight * 0.059,
                                child: Align(
                                  alignment: Alignment(0.00, 0.00),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          flex: 37,
                                          child: Padding(
                                              padding: EdgeInsets.only(),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.323,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.059,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: AutoSizeText(
                                                      'Transactions',
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
                                          flex: 42,
                                        ),
                                        Flexible(
                                          flex: 4,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.02,
                                              ),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.028,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.034,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: AutoSizeText(
                                                      'ALL',
                                                      style: TextStyle(
                                                        fontFamily: 'Prompt',
                                                        fontSize: 11.0,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        letterSpacing:
                                                            0.4124999940395355,
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
                                          flex: 5,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.02,
                                              ),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.038,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.034,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: AutoSizeText(
                                                      'SEND',
                                                      style: TextStyle(
                                                        fontFamily: 'Prompt',
                                                        fontSize: 11.0,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        letterSpacing:
                                                            0.4124999940395355,
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
                                          flex: 7,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.02,
                                              ),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.055,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.034,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: AutoSizeText(
                                                      'RECENT',
                                                      style: TextStyle(
                                                        fontFamily: 'Prompt',
                                                        fontSize: 11.0,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        letterSpacing:
                                                            0.4124999940395355,
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
                        flex: 6,
                      ),
                      Flexible(
                        flex: 17,
                        child: Padding(
                            padding: EdgeInsets.only(),
                            child:
                                LayoutBuilder(builder: (context, constraints) {
                              return Transactions(
                                constraints,
                              );
                            })),
                      ),
                      Spacer(
                        flex: 2,
                      ),
                      Flexible(
                        flex: 17,
                        child: Padding(
                            padding: EdgeInsets.only(),
                            child:
                                LayoutBuilder(builder: (context, constraints) {
                              return Transactions(
                                constraints,
                              );
                            })),
                      ),
                      Spacer(
                        flex: 2,
                      ),
                      Flexible(
                        flex: 17,
                        child: Padding(
                            padding: EdgeInsets.only(),
                            child:
                                LayoutBuilder(builder: (context, constraints) {
                              return Transactions(
                                constraints,
                              );
                            })),
                      ),
                      Spacer(
                        flex: 2,
                      ),
                      Flexible(
                        flex: 17,
                        child: Padding(
                            padding: EdgeInsets.only(),
                            child:
                                LayoutBuilder(builder: (context, constraints) {
                              return Transactions(
                                constraints,
                              );
                            })),
                      ),
                      Spacer(
                        flex: 6,
                      ),
                      Flexible(
                        flex: 14,
                        child: Padding(
                            padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.61,
                            ),
                            child:
                                LayoutBuilder(builder: (context, constraints) {
                              return ButtonActive(
                                constraints,
                              );
                            })),
                      ),
                    ]),
              )),
        ));
  }
}
