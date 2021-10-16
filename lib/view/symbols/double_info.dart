import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class DoubleInfo extends StatelessWidget {
  final constraints;

  DoubleInfo(
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
          alignment: Alignment(-0.14, -0.43),
          child: Container(
              width: constraints.maxWidth * 0.955,
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
                            child: Container(
                              width: constraints.maxWidth * 0.113,
                              height: constraints.maxHeight * 0.778,
                              decoration: BoxDecoration(
                                color: Color(0x00000000),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(18.0)),
                                border: Border.all(
                                  color: Color(0x00000000),
                                ),
                              ),
                            )),
                      ),
                      Spacer(
                        flex: 3,
                      ),
                      Flexible(
                        flex: 81,
                        child: Padding(
                            padding: EdgeInsets.only(),
                            child: Container(
                                width: constraints.maxWidth * 0.768,
                                height: constraints.maxHeight * 0.844,
                                child: Align(
                                  alignment: Alignment(0.00, 0.00),
                                  child: Stack(children: [
                                    Positioned(
                                      left: constraints.maxWidth * 0.000,
                                      right: constraints.maxWidth * 0.000,
                                      top: constraints.maxHeight * 0.000,
                                      bottom: constraints.maxHeight * 0.378,
                                      child: Container(
                                          width: constraints.maxWidth * 0.768,
                                          height: constraints.maxHeight * 0.467,
                                          child: Align(
                                            alignment: Alignment(0.00, 0.00),
                                            child: AutoSizeText(
                                              'Type something',
                                              style: TextStyle(
                                                fontFamily: 'Prompt',
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FontStyle.normal,
                                                letterSpacing: 0.0,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          )),
                                    ),
                                    Positioned(
                                      left: constraints.maxWidth * 0.000,
                                      right: constraints.maxWidth * 0.000,
                                      top: constraints.maxHeight * 0.444,
                                      bottom: constraints.maxHeight * 0.000,
                                      child: Container(
                                          width: constraints.maxWidth * 0.768,
                                          height: constraints.maxHeight * 0.400,
                                          child: Align(
                                            alignment: Alignment(0.00, 0.00),
                                            child: AutoSizeText(
                                              'Type something',
                                              style: TextStyle(
                                                fontFamily: 'Prompt',
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w100,
                                                fontStyle: FontStyle.normal,
                                                letterSpacing: 0.0,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          )),
                                    ),
                                  ]),
                                ))),
                      ),
                      Spacer(
                        flex: 4,
                      ),
                      Flexible(
                        flex: 2,
                        child: Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.height * 0.40,
                              top: MediaQuery.of(context).size.height * 0.34,
                            ),
                            child: Image.asset(
                              'assets/images/0_12276.png',
                              width: constraints.maxWidth * 0.015,
                              height: constraints.maxHeight * 0.100,
                            )),
                      )
                    ]),
              )),
        ));
  }
}
