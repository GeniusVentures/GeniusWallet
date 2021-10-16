import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CoverSendCryptoDesktop extends StatelessWidget {
  final constraints;

  CoverSendCryptoDesktop(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: constraints.maxWidth * 0.801,
        height: constraints.maxHeight * 0.799,
        child: Align(
          alignment: Alignment(0.00, 0.00),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 13,
                  child: Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.06,
                        right: MediaQuery.of(context).size.width * 0.06,
                      ),
                      child: Container(
                          width: constraints.maxWidth * 0.686,
                          height: constraints.maxHeight * 0.096,
                          child: Align(
                            alignment: Alignment(0.00, 0.00),
                            child: AutoSizeText(
                              'Send eth',
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
                          ))),
                ),
                Spacer(
                  flex: 32,
                ),
                Flexible(
                  flex: 57,
                  child: Padding(
                      padding: EdgeInsets.only(),
                      child: Container(
                          width: constraints.maxWidth * 0.801,
                          height: constraints.maxHeight * 0.451,
                          child: Align(
                            alignment: Alignment(0.00, 0.00),
                            child: Stack(children: [
                              Image.asset(
                                'assets/images/0_12700.png',
                                width: constraints.maxWidth * 0.801,
                                height: constraints.maxHeight * 0.451,
                              ),
                              Positioned(
                                left: constraints.maxWidth * 0.045,
                                right: constraints.maxWidth * 0.048,
                                top: constraints.maxHeight * 0.060,
                                bottom: constraints.maxHeight * 0.056,
                                child: Container(
                                    width: constraints.maxWidth * 0.707,
                                    height: constraints.maxHeight * 0.335,
                                    child: Align(
                                      alignment: Alignment(0.00, 0.00),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              flex: 35,
                                              child: Padding(
                                                  padding: EdgeInsets.only(),
                                                  child: Container(
                                                      width:
                                                          constraints.maxWidth *
                                                              0.707,
                                                      height: constraints
                                                              .maxHeight *
                                                          0.116,
                                                      child: Align(
                                                        alignment: Alignment(
                                                            0.00, 0.00),
                                                        child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Flexible(
                                                                flex: 65,
                                                                child: Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .only(),
                                                                    child: Container(
                                                                        width: constraints.maxWidth * 0.455,
                                                                        height: constraints.maxHeight * 0.116,
                                                                        child: Align(
                                                                          alignment: Alignment(
                                                                              0.00,
                                                                              0.00),
                                                                          child:
                                                                              AutoSizeText(
                                                                            'Recipient Address',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Prompt',
                                                                              fontSize: 18.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FontStyle.normal,
                                                                              letterSpacing: 0.0,
                                                                              color: Color(0xff575757),
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                          ),
                                                                        ))),
                                                              ),
                                                              Spacer(
                                                                flex: 5,
                                                              ),
                                                              Flexible(
                                                                flex: 19,
                                                                child: Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .only(
                                                                      bottom: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0.01,
                                                                      top: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0.01,
                                                                    ),
                                                                    child: Container(
                                                                        width: constraints.maxWidth * 0.128,
                                                                        height: constraints.maxHeight * 0.090,
                                                                        child: Align(
                                                                          alignment: Alignment(
                                                                              0.00,
                                                                              0.00),
                                                                          child:
                                                                              AutoSizeText(
                                                                            'Paste',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Prompt',
                                                                              fontSize: 14.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FontStyle.normal,
                                                                              letterSpacing: 0.0,
                                                                              color: Color(0xff003698),
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.right,
                                                                          ),
                                                                        ))),
                                                              ),
                                                              Spacer(
                                                                flex: 7,
                                                              ),
                                                              Flexible(
                                                                flex: 7,
                                                                child: Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .only(
                                                                      bottom: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0.03,
                                                                      top: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0.02,
                                                                    ),
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/images/0_12707.png',
                                                                      width: constraints
                                                                              .maxWidth *
                                                                          0.048,
                                                                      height: constraints
                                                                              .maxHeight *
                                                                          0.069,
                                                                    )),
                                                              )
                                                            ]),
                                                      ))),
                                            ),
                                            Spacer(
                                              flex: 31,
                                            ),
                                            Flexible(
                                              flex: 35,
                                              child: Padding(
                                                  padding: EdgeInsets.only(
                                                    right:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.03,
                                                  ),
                                                  child: Container(
                                                      width:
                                                          constraints.maxWidth *
                                                              0.676,
                                                      height: constraints
                                                              .maxHeight *
                                                          0.116,
                                                      child: Align(
                                                        alignment: Alignment(
                                                            0.00, 0.00),
                                                        child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Flexible(
                                                                flex: 53,
                                                                child: Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .only(),
                                                                    child: Container(
                                                                        width: constraints.maxWidth * 0.354,
                                                                        height: constraints.maxHeight * 0.116,
                                                                        child: Align(
                                                                          alignment: Alignment(
                                                                              0.00,
                                                                              0.00),
                                                                          child:
                                                                              AutoSizeText(
                                                                            'ETH Amount',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Prompt',
                                                                              fontSize: 18.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FontStyle.normal,
                                                                              letterSpacing: 0.0,
                                                                              color: Color(0xff575757),
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                          ),
                                                                        ))),
                                                              ),
                                                              Spacer(
                                                                flex: 15,
                                                              ),
                                                              Flexible(
                                                                flex: 33,
                                                                child: Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .only(
                                                                      bottom: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0.01,
                                                                      top: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0.01,
                                                                    ),
                                                                    child: Container(
                                                                        width: constraints.maxWidth * 0.221,
                                                                        height: constraints.maxHeight * 0.090,
                                                                        child: Align(
                                                                          alignment: Alignment(
                                                                              0.00,
                                                                              0.00),
                                                                          child:
                                                                              AutoSizeText(
                                                                            'Max ETH',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Prompt',
                                                                              fontSize: 14.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FontStyle.normal,
                                                                              letterSpacing: 0.0,
                                                                              color: Color(0xff003698),
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.right,
                                                                          ),
                                                                        ))),
                                                              )
                                                            ]),
                                                      ))),
                                            ),
                                          ]),
                                    )),
                              ),
                            ]),
                          ))),
                ),
              ]),
        ));
  }
}
