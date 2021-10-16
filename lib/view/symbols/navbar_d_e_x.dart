import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class NavbarDEX extends StatelessWidget {
  final constraints;

  NavbarDEX(
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
            Container(
              width: constraints.maxWidth * 1.000,
              height: constraints.maxHeight * 1.000,
              decoration: BoxDecoration(
                color: Color(0xff0050c4),
              ),
            ),
            Positioned(
              left: constraints.maxWidth * 0.123,
              right: constraints.maxWidth * 0.117,
              top: constraints.maxHeight * 0.123,
              bottom: constraints.maxHeight * 0.506,
              child: Container(
                  width: constraints.maxWidth * 0.760,
                  height: constraints.maxHeight * 0.370,
                  child: Align(
                    alignment: Alignment(0.00, 0.00),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 100,
                            child: Padding(
                                padding: EdgeInsets.only(),
                                child: Container(
                                    width: constraints.maxWidth * 0.760,
                                    height: constraints.maxHeight * 0.370,
                                    child: Align(
                                      alignment: Alignment(0.00, 0.00),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              flex: 9,
                                              child: Padding(
                                                  padding: EdgeInsets.only(),
                                                  child: Image.asset(
                                                    'assets/images/0_12401.png',
                                                    width:
                                                        constraints.maxWidth *
                                                            0.061,
                                                    height:
                                                        constraints.maxHeight *
                                                            0.370,
                                                  )),
                                            ),
                                            Spacer(
                                              flex: 84,
                                            ),
                                            Flexible(
                                              flex: 9,
                                              child: Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.04,
                                                    top: MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.02,
                                                  ),
                                                  child: Image.asset(
                                                    'assets/images/0_12407.png',
                                                    width:
                                                        constraints.maxWidth *
                                                            0.064,
                                                    height:
                                                        constraints.maxHeight *
                                                            0.314,
                                                  )),
                                            )
                                          ]),
                                    ))),
                          ),
                          Flexible(
                            flex: 8,
                            child: Padding(
                                padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.34,
                                  right:
                                      MediaQuery.of(context).size.width * 0.35,
                                ),
                                child: Image.asset(
                                  'assets/images/0_12402.png',
                                  width: constraints.maxWidth * 0.067,
                                  height: constraints.maxHeight * 0.026,
                                )),
                          ),
                        ]),
                  )),
            ),
            Positioned(
              left: constraints.maxWidth * 0.102,
              right: constraints.maxWidth * 0.088,
              top: constraints.maxHeight * 0.494,
              bottom: constraints.maxHeight * 0.312,
              child: Container(
                  width: constraints.maxWidth * 0.810,
                  height: constraints.maxHeight * 0.195,
                  child: Align(
                    alignment: Alignment(0.00, 0.00),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 100,
                            child: Padding(
                                padding: EdgeInsets.only(
                                  right:
                                      MediaQuery.of(context).size.width * 0.39,
                                ),
                                child: Container(
                                    width: constraints.maxWidth * 0.424,
                                    height: constraints.maxHeight * 0.195,
                                    child: Align(
                                      alignment: Alignment(0.00, 0.00),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              flex: 25,
                                              child: Padding(
                                                  padding: EdgeInsets.only(),
                                                  child: Container(
                                                      width:
                                                          constraints.maxWidth *
                                                              0.104,
                                                      height: constraints
                                                              .maxHeight *
                                                          0.195,
                                                      child: Align(
                                                        alignment: Alignment(
                                                            0.00, 0.00),
                                                        child: AutoSizeText(
                                                          'Wallet',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Prompt',
                                                            fontSize: 10.0,
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
                                            Spacer(
                                              flex: 63,
                                            ),
                                            Flexible(
                                              flex: 13,
                                              child: Padding(
                                                  padding: EdgeInsets.only(),
                                                  child: Container(
                                                      width:
                                                          constraints.maxWidth *
                                                              0.053,
                                                      height: constraints
                                                              .maxHeight *
                                                          0.195,
                                                      child: Align(
                                                        alignment: Alignment(
                                                            0.00, 0.00),
                                                        child: AutoSizeText(
                                                          'Dex',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Prompt',
                                                            fontSize: 10.0,
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
                          Flexible(
                            flex: 100,
                            child: Padding(
                                padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.69,
                                ),
                                child: Container(
                                    width: constraints.maxWidth * 0.123,
                                    height: constraints.maxHeight * 0.195,
                                    child: Align(
                                      alignment: Alignment(0.00, 0.00),
                                      child: AutoSizeText(
                                        'settings',
                                        style: TextStyle(
                                          fontFamily: 'Prompt',
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.w300,
                                          fontStyle: FontStyle.normal,
                                          letterSpacing: 0.0,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ))),
                          ),
                        ]),
                  )),
            ),
          ]),
        ));
  }
}
