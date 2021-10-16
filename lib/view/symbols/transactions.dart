import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Transactions extends StatelessWidget {
  final constraints;

  Transactions(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: constraints.maxWidth * 1.000,
        height: constraints.maxHeight * 1.000,
        decoration: BoxDecoration(
          color: Color(0xff004abb),
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
          border: Border.all(
            color: Color(0xff979797),
          ),
        ),
        child: Align(
          alignment: Alignment(0.42, 0.13),
          child: Container(
              width: constraints.maxWidth * 0.952,
              height: constraints.maxHeight * 0.714,
              child: Align(
                alignment: Alignment(0.00, 0.00),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 46,
                        child: Padding(
                            padding: EdgeInsets.only(),
                            child: Container(
                                width: constraints.maxWidth * 0.952,
                                height: constraints.maxHeight * 0.325,
                                child: Align(
                                  alignment: Alignment(0.00, 0.00),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          flex: 36,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.03,
                                              ),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.333,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.293,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: AutoSizeText(
                                                      '16:23, 12 dec 2018',
                                                      style: TextStyle(
                                                        fontFamily: 'Prompt',
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        letterSpacing: 0.25,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ))),
                                        ),
                                        Spacer(
                                          flex: 41,
                                        ),
                                        Flexible(
                                          flex: 24,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.03,
                                              ),
                                              child: Container(
                                                  width: constraints.maxWidth *
                                                      0.228,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.293,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: Stack(children: [
                                                      Container(
                                                          width: constraints
                                                                  .maxWidth *
                                                              0.228,
                                                          height: constraints
                                                                  .maxHeight *
                                                              0.293,
                                                          child: Align(
                                                            alignment:
                                                                Alignment(
                                                                    0.00, 0.00),
                                                            child: AutoSizeText(
                                                              '0.009 ETH',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Prompt',
                                                                fontSize: 14.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .normal,
                                                                letterSpacing:
                                                                    0.30000001192092896,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                            ),
                                                          )),
                                                      Positioned(
                                                        left: constraints
                                                                .maxWidth *
                                                            0.081,
                                                        right: constraints
                                                                .maxWidth *
                                                            0.123,
                                                        top: constraints
                                                                .maxHeight *
                                                            0.061,
                                                        bottom: constraints
                                                                .maxHeight *
                                                            0.078,
                                                        child: Image.asset(
                                                          'assets/images/0_12594.png',
                                                          width: constraints
                                                                  .maxWidth *
                                                              0.024,
                                                          height: constraints
                                                                  .maxHeight *
                                                              0.153,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        left: constraints
                                                                .maxWidth *
                                                            0.081,
                                                        right: constraints
                                                                .maxWidth *
                                                            0.123,
                                                        top: constraints
                                                                .maxHeight *
                                                            0.061,
                                                        bottom: constraints
                                                                .maxHeight *
                                                            0.078,
                                                        child: Image.asset(
                                                          'assets/images/0_12593.png',
                                                          width: constraints
                                                                  .maxWidth *
                                                              0.024,
                                                          height: constraints
                                                                  .maxHeight *
                                                              0.153,
                                                        ),
                                                      ),
                                                    ]),
                                                  ))),
                                        )
                                      ]),
                                ))),
                      ),
                      Spacer(
                        flex: 2,
                      ),
                      Flexible(
                        flex: 53,
                        child: Padding(
                            padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.10,
                            ),
                            child: Container(
                                width: constraints.maxWidth * 0.848,
                                height: constraints.maxHeight * 0.376,
                                child: Align(
                                  alignment: Alignment(0.00, 0.00),
                                  child: AutoSizeText(
                                    '1PRj85hu9RXPZTzxtko9stfs6nRo1vyrQB',
                                    style: TextStyle(
                                      fontFamily: 'Prompt',
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.normal,
                                      letterSpacing: 0.30000001192092896,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ))),
                      ),
                    ]),
              )),
        ));
  }
}
