import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class NavbarDesktop extends StatelessWidget {
  final constraints;

  NavbarDesktop(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: constraints.maxWidth * 1.000,
        height: constraints.maxHeight * 1.000,
        child: Align(
          alignment: Alignment(0.00, 0.00),
          child: Stack(children: [
            Image.asset(
              'assets/images/0_12542.png',
              width: constraints.maxWidth * 1.000,
              height: constraints.maxHeight * 1.000,
            ),
            Positioned(
              left: constraints.maxWidth * 0.011,
              right: constraints.maxWidth * 0.012,
              top: constraints.maxHeight * 0.119,
              bottom: constraints.maxHeight * 0.134,
              child: Container(
                  width: constraints.maxWidth * 0.977,
                  height: constraints.maxHeight * 0.746,
                  child: Align(
                    alignment: Alignment(0.00, 0.00),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 3,
                            child: Padding(
                                padding: EdgeInsets.only(),
                                child: Image.asset(
                                  'assets/images/0_12556.png',
                                  width: constraints.maxWidth * 0.026,
                                  height: constraints.maxHeight * 0.746,
                                )),
                          ),
                          Spacer(
                            flex: 90,
                          ),
                          Flexible(
                            flex: 3,
                            child: Padding(
                                padding: EdgeInsets.only(),
                                child: Image.asset(
                                  'assets/images/0_12550.png',
                                  width: constraints.maxWidth * 0.026,
                                  height: constraints.maxHeight * 0.746,
                                )),
                          ),
                          Flexible(
                            flex: 3,
                            child: Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).size.height * 0.57,
                                  top:
                                      MediaQuery.of(context).size.height * 0.14,
                                ),
                                child: Image.asset(
                                  'assets/images/0_12552.png',
                                  width: constraints.maxWidth * 0.023,
                                  height: constraints.maxHeight * 0.030,
                                )),
                          ),
                          Spacer(
                            flex: 97,
                          ),
                          Flexible(
                            flex: 1,
                            child: Padding(
                                padding: EdgeInsets.only(
                                  top:
                                      MediaQuery.of(context).size.height * 0.61,
                                ),
                                child: Image.asset(
                                  'assets/images/0_12551.png',
                                  width: constraints.maxWidth * 0.007,
                                  height: constraints.maxHeight * 0.134,
                                )),
                          )
                        ]),
                  )),
            ),
            Positioned(
              left: constraints.maxWidth * 0.746,
              right: constraints.maxWidth * 0.065,
              top: constraints.maxHeight * 0.284,
              bottom: constraints.maxHeight * 0.291,
              child: Container(
                  width: constraints.maxWidth * 0.188,
                  height: constraints.maxHeight * 0.425,
                  child: Align(
                    alignment: Alignment(0.00, 0.00),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 28,
                            child: Padding(
                                padding: EdgeInsets.only(),
                                child: Container(
                                    width: constraints.maxWidth * 0.052,
                                    height: constraints.maxHeight * 0.425,
                                    child: Align(
                                      alignment: Alignment(0.00, 0.00),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              flex: 24,
                                              child: Padding(
                                                  padding: EdgeInsets.only(),
                                                  child: Image.asset(
                                                    'assets/images/0_12560.png',
                                                    width:
                                                        constraints.maxWidth *
                                                            0.012,
                                                    height:
                                                        constraints.maxHeight *
                                                            0.425,
                                                  )),
                                            ),
                                            Spacer(
                                              flex: 7,
                                            ),
                                            Flexible(
                                              flex: 71,
                                              child: Padding(
                                                  padding: EdgeInsets.only(
                                                    top: MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.01,
                                                  ),
                                                  child: Container(
                                                      width:
                                                          constraints.maxWidth *
                                                              0.036,
                                                      height: constraints
                                                              .maxHeight *
                                                          0.403,
                                                      child: Align(
                                                        alignment: Alignment(
                                                            0.00, 0.00),
                                                        child: AutoSizeText(
                                                          'Wallet',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Prompt',
                                                            fontSize: 18.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            fontStyle: FontStyle
                                                                .normal,
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
                            flex: 11,
                          ),
                          Flexible(
                            flex: 21,
                            child: Padding(
                                padding: EdgeInsets.only(
                                  top:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),
                                child: Container(
                                    width: constraints.maxWidth * 0.038,
                                    height: constraints.maxHeight * 0.403,
                                    child: Align(
                                      alignment: Alignment(0.00, 0.00),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Flexible(
                                              flex: 49,
                                              child: Padding(
                                                  padding: EdgeInsets.only(),
                                                  child: Container(
                                                      width:
                                                          constraints.maxWidth *
                                                              0.019,
                                                      height: constraints
                                                              .maxHeight *
                                                          0.403,
                                                      child: Align(
                                                        alignment: Alignment(
                                                            0.00, 0.00),
                                                        child: AutoSizeText(
                                                          'Dex',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Prompt',
                                                            fontSize: 18.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            letterSpacing: 0.0,
                                                            color: Colors.white,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ))),
                                            ),
                                            Flexible(
                                              flex: 35,
                                              child: Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.28,
                                                    top: MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.10,
                                                  ),
                                                  child: Image.asset(
                                                    'assets/images/0_12563.png',
                                                    width:
                                                        constraints.maxWidth *
                                                            0.013,
                                                    height:
                                                        constraints.maxHeight *
                                                            0.030,
                                                  )),
                                            )
                                          ]),
                                    ))),
                          ),
                          Spacer(
                            flex: 11,
                          ),
                          Flexible(
                            flex: 31,
                            child: Padding(
                                padding: EdgeInsets.only(
                                  top:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),
                                child: Container(
                                    width: constraints.maxWidth * 0.058,
                                    height: constraints.maxHeight * 0.403,
                                    child: Align(
                                      alignment: Alignment(0.00, 0.00),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              flex: 90,
                                              child: Padding(
                                                  padding: EdgeInsets.only(
                                                    right:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.05,
                                                  ),
                                                  child: Image.asset(
                                                    'assets/images/0_12570.png',
                                                    width:
                                                        constraints.maxWidth *
                                                            0.013,
                                                    height:
                                                        constraints.maxHeight *
                                                            0.361,
                                                  )),
                                            ),
                                            Flexible(
                                              flex: 100,
                                              child: Padding(
                                                  padding: EdgeInsets.only(
                                                    left: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.02,
                                                  ),
                                                  child: Container(
                                                      width:
                                                          constraints.maxWidth *
                                                              0.043,
                                                      height: constraints
                                                              .maxHeight *
                                                          0.403,
                                                      child: Align(
                                                        alignment: Alignment(
                                                            0.00, 0.00),
                                                        child: AutoSizeText(
                                                          'settings',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Prompt',
                                                            fontSize: 18.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            letterSpacing: 0.0,
                                                            color: Colors.white,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ))),
                                            ),
                                          ]),
                                    ))),
                          )
                        ]),
                  )),
            ),
          ]),
        ));
  }
}
