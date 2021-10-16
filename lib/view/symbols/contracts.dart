import 'package:flutter/material.dart';
import './contract_icon.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Contracts extends StatelessWidget {
  final constraints;

  Contracts(
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
          alignment: Alignment(-0.08, -0.43),
          child: Container(
              width: constraints.maxWidth * 0.958,
              height: constraints.maxHeight * 0.844,
              child: Align(
                alignment: Alignment(0.00, 0.00),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 12,
                        child: Padding(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.07,
                            ),
                            child:
                                LayoutBuilder(builder: (context, constraints) {
                              return ContractIcon(
                                constraints,
                              );
                            })),
                      ),
                      Spacer(
                        flex: 3,
                      ),
                      Flexible(
                        flex: 86,
                        child: Padding(
                            padding: EdgeInsets.only(),
                            child: Container(
                                width: constraints.maxWidth * 0.823,
                                height: constraints.maxHeight * 0.844,
                                child: Align(
                                  alignment: Alignment(0.00, 0.00),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          flex: 82,
                                          child: Padding(
                                              padding: EdgeInsets.only(),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.823,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.689,
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
                                                            flex: 79,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(
                                                                  bottom: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.22,
                                                                ),
                                                                child:
                                                                    Container(
                                                                        width: constraints.maxWidth *
                                                                            0.642,
                                                                        height: constraints.maxHeight *
                                                                            0.467,
                                                                        child:
                                                                            Align(
                                                                          alignment: Alignment(
                                                                              0.00,
                                                                              0.00),
                                                                          child:
                                                                              AutoSizeText(
                                                                            'Smart Contract Call',
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
                                                          ),
                                                          Spacer(
                                                            flex: 1,
                                                          ),
                                                          Flexible(
                                                            flex: 22,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(
                                                                  top: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.22,
                                                                ),
                                                                child:
                                                                    Container(
                                                                        width: constraints.maxWidth *
                                                                            0.181,
                                                                        height: constraints.maxHeight *
                                                                            0.467,
                                                                        child:
                                                                            Align(
                                                                          alignment: Alignment(
                                                                              0.00,
                                                                              0.00),
                                                                          child:
                                                                              AutoSizeText(
                                                                            'ETH',
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
                                                                                TextAlign.right,
                                                                          ),
                                                                        ))),
                                                          )
                                                        ]),
                                                  ))),
                                        ),
                                        Flexible(
                                          flex: 48,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05,
                                              ),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.768,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.400,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: AutoSizeText(
                                                      'To: 0x03352...6b9bF6',
                                                      style: TextStyle(
                                                        fontFamily: 'Prompt',
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.w100,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        letterSpacing: 0.0,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ))),
                                        ),
                                      ]),
                                ))),
                      )
                    ]),
              )),
        ));
  }
}
