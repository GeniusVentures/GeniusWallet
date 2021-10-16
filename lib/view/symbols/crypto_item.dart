import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CryptoItem extends StatelessWidget {
  final constraints;

  CryptoItem(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: constraints.maxWidth * 1.000,
        height: constraints.maxHeight * 0.736,
        child: Align(
          alignment: Alignment(0.00, 0.00),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 4,
                  child: Padding(
                      padding: EdgeInsets.only(),
                      child: Image.asset(
                        'assets/images/0_12431.png',
                        width: constraints.maxWidth * 1.000,
                        height: constraints.maxHeight * 0.027,
                      )),
                ),
                Spacer(
                  flex: 23,
                ),
                Flexible(
                  flex: 74,
                  child: Padding(
                      padding: EdgeInsets.only(),
                      child: Container(
                          width: constraints.maxWidth * 1.000,
                          height: constraints.maxHeight * 0.541,
                          child: Align(
                            alignment: Alignment(0.00, 0.00),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 14,
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.04,
                                        ),
                                        child: Image.asset(
                                          'assets/images/0_12432.png',
                                          width: constraints.maxWidth * 0.131,
                                          height: constraints.maxHeight * 0.497,
                                        )),
                                  ),
                                  Spacer(
                                    flex: 5,
                                  ),
                                  Flexible(
                                    flex: 83,
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.11,
                                        ),
                                        child: Container(
                                            width: constraints.maxWidth * 0.825,
                                            height:
                                                constraints.maxHeight * 0.432,
                                            child: Align(
                                              alignment: Alignment(0.00, 0.00),
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Flexible(
                                                      flex: 38,
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.only(),
                                                          child: Container(
                                                              width: constraints
                                                                      .maxWidth *
                                                                  0.825,
                                                              height: constraints
                                                                      .maxHeight *
                                                                  0.162,
                                                              child: Align(
                                                                alignment:
                                                                    Alignment(
                                                                        0.00,
                                                                        0.00),
                                                                child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Flexible(
                                                                        flex:
                                                                            52,
                                                                        child: Padding(
                                                                            padding: EdgeInsets.only(),
                                                                            child: Container(
                                                                                width: constraints.maxWidth * 0.421,
                                                                                height: constraints.maxHeight * 0.162,
                                                                                child: Align(
                                                                                  alignment: Alignment(0.00, 0.00),
                                                                                  child: AutoSizeText(
                                                                                    'Crypto',
                                                                                    style: TextStyle(
                                                                                      fontFamily: 'Prompt',
                                                                                      fontSize: 14.0,
                                                                                      fontWeight: FontWeight.w400,
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
                                                                        flex:
                                                                            48,
                                                                        child: Padding(
                                                                            padding: EdgeInsets.only(),
                                                                            child: Container(
                                                                                width: constraints.maxWidth * 0.393,
                                                                                height: constraints.maxHeight * 0.162,
                                                                                child: Align(
                                                                                  alignment: Alignment(0.00, 0.00),
                                                                                  child: AutoSizeText(
                                                                                    '0 BTC',
                                                                                    style: TextStyle(
                                                                                      fontFamily: 'Prompt',
                                                                                      fontSize: 14.0,
                                                                                      fontWeight: FontWeight.w500,
                                                                                      fontStyle: FontStyle.normal,
                                                                                      letterSpacing: 0.0,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                    textAlign: TextAlign.right,
                                                                                  ),
                                                                                ))),
                                                                      )
                                                                    ]),
                                                              ))),
                                                    ),
                                                    Spacer(
                                                      flex: 25,
                                                    ),
                                                    Flexible(
                                                      flex: 38,
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.only(),
                                                          child: Container(
                                                              width: constraints
                                                                      .maxWidth *
                                                                  0.825,
                                                              height: constraints
                                                                      .maxHeight *
                                                                  0.162,
                                                              child: Align(
                                                                alignment:
                                                                    Alignment(
                                                                        0.00,
                                                                        0.00),
                                                                child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Flexible(
                                                                        flex:
                                                                            26,
                                                                        child: Padding(
                                                                            padding: EdgeInsets.only(),
                                                                            child: Container(
                                                                                width: constraints.maxWidth * 0.210,
                                                                                height: constraints.maxHeight * 0.162,
                                                                                child: Align(
                                                                                  alignment: Alignment(0.00, 0.00),
                                                                                  child: AutoSizeText(
                                                                                    '\$46,309.50',
                                                                                    style: TextStyle(
                                                                                      fontFamily: 'Prompt',
                                                                                      fontSize: 11.0,
                                                                                      fontWeight: FontWeight.w300,
                                                                                      fontStyle: FontStyle.normal,
                                                                                      letterSpacing: 0.0,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                    textAlign: TextAlign.left,
                                                                                  ),
                                                                                ))),
                                                                      ),
                                                                      Spacer(
                                                                        flex: 4,
                                                                      ),
                                                                      Flexible(
                                                                        flex:
                                                                            23,
                                                                        child: Padding(
                                                                            padding: EdgeInsets.only(),
                                                                            child: Container(
                                                                                width: constraints.maxWidth * 0.185,
                                                                                height: constraints.maxHeight * 0.162,
                                                                                child: Align(
                                                                                  alignment: Alignment(0.00, 0.00),
                                                                                  child: AutoSizeText(
                                                                                    '+4.18%',
                                                                                    style: TextStyle(
                                                                                      fontFamily: 'Prompt',
                                                                                      fontSize: 11.0,
                                                                                      fontWeight: FontWeight.w300,
                                                                                      fontStyle: FontStyle.normal,
                                                                                      letterSpacing: 0.0,
                                                                                      color: Color(0xff00f1ac),
                                                                                    ),
                                                                                    textAlign: TextAlign.left,
                                                                                  ),
                                                                                ))),
                                                                      ),
                                                                      Spacer(
                                                                        flex:
                                                                            31,
                                                                      ),
                                                                      Flexible(
                                                                        flex:
                                                                            19,
                                                                        child: Padding(
                                                                            padding: EdgeInsets.only(),
                                                                            child: Container(
                                                                                width: constraints.maxWidth * 0.157,
                                                                                height: constraints.maxHeight * 0.162,
                                                                                child: Align(
                                                                                  alignment: Alignment(0.00, 0.00),
                                                                                  child: AutoSizeText(
                                                                                    '\$20.99',
                                                                                    style: TextStyle(
                                                                                      fontFamily: 'Prompt',
                                                                                      fontSize: 11.0,
                                                                                      fontWeight: FontWeight.w300,
                                                                                      fontStyle: FontStyle.normal,
                                                                                      letterSpacing: 0.0,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                    textAlign: TextAlign.right,
                                                                                  ),
                                                                                ))),
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
              ]),
        ));
  }
}
