import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class GeniusSlider extends StatelessWidget {
  final constraints;

  GeniusSlider(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: constraints.maxWidth * 1.000,
        height: constraints.maxHeight * 1.024,
        child: Align(
          alignment: Alignment(0.00, 0.00),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 33,
                  child: Padding(
                      padding: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * 0.06,
                      ),
                      child: Container(
                          width: constraints.maxWidth * 0.939,
                          height: constraints.maxHeight * 0.329,
                          child: Align(
                            alignment: Alignment(0.00, 0.00),
                            child: AutoSizeText(
                              'Type',
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 18.0,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                                letterSpacing: 0.0,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ))),
                ),
                Spacer(
                  flex: 17,
                ),
                Flexible(
                  flex: 15,
                  child: Padding(
                      padding: EdgeInsets.only(),
                      child: Container(
                          width: constraints.maxWidth * 1.000,
                          height: constraints.maxHeight * 0.146,
                          child: Align(
                            alignment: Alignment(0.00, 0.00),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    flex: 50,
                                    child: Padding(
                                        padding: EdgeInsets.only(),
                                        child: Container(
                                            width: constraints.maxWidth * 1.000,
                                            height:
                                                constraints.maxHeight * 0.073,
                                            child: Align(
                                              alignment: Alignment(0.00, 0.00),
                                              child: Stack(children: [
                                                Container(
                                                  width: constraints.maxWidth *
                                                      1.000,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.073,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xff0068ef),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                154.0)),
                                                    border: Border.all(
                                                      color: Color(0x00000000),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: constraints.maxWidth *
                                                      0.000,
                                                  right: constraints.maxWidth *
                                                      0.552,
                                                  top: constraints.maxHeight *
                                                      0.000,
                                                  bottom:
                                                      constraints.maxHeight *
                                                          0.000,
                                                  child: Container(
                                                    width:
                                                        constraints.maxWidth *
                                                            0.448,
                                                    height:
                                                        constraints.maxHeight *
                                                            0.073,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  154.0)),
                                                      border: Border.all(
                                                        color:
                                                            Color(0x00000000),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ]),
                                            ))),
                                  ),
                                  Flexible(
                                    flex: 100,
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.42,
                                          right: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.54,
                                        ),
                                        child: Image.asset(
                                          'assets/images/0_12538.png',
                                          width: constraints.maxWidth * 0.039,
                                          height: constraints.maxHeight * 0.146,
                                        )),
                                  ),
                                ]),
                          ))),
                ),
                Flexible(
                  flex: 37,
                  child: Padding(
                      padding: EdgeInsets.only(),
                      child: Container(
                          width: constraints.maxWidth * 1.000,
                          height: constraints.maxHeight * 0.378,
                          child: Align(
                            alignment: Alignment(0.00, 0.00),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.29,
                                        ),
                                        child: Image.asset(
                                          'assets/images/0_12539.png',
                                          width: constraints.maxWidth * 0.006,
                                          height: constraints.maxHeight * 0.067,
                                        )),
                                  ),
                                  Spacer(
                                    flex: 42,
                                  ),
                                  Flexible(
                                    flex: 14,
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.05,
                                        ),
                                        child: Container(
                                            width: constraints.maxWidth * 0.135,
                                            height:
                                                constraints.maxHeight * 0.329,
                                            child: Align(
                                              alignment: Alignment(0.00, 0.00),
                                              child: AutoSizeText(
                                                'Type',
                                                style: TextStyle(
                                                  fontFamily: 'Prompt',
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle: FontStyle.normal,
                                                  letterSpacing: 0.0,
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ))),
                                  ),
                                  Flexible(
                                    flex: 8,
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.05,
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.12,
                                        ),
                                        child: Container(
                                            width: constraints.maxWidth * 0.074,
                                            height:
                                                constraints.maxHeight * 0.183,
                                            child: Align(
                                              alignment: Alignment(0.00, 0.00),
                                              child: AutoSizeText(
                                                'Type',
                                                style: TextStyle(
                                                  fontFamily: 'Prompt',
                                                  fontSize: 10.0,
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
                                    flex: 92,
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.29,
                                        ),
                                        child: Image.asset(
                                          'assets/images/0_12540.png',
                                          width: constraints.maxWidth * 0.006,
                                          height: constraints.maxHeight * 0.067,
                                        )),
                                  ),
                                  Flexible(
                                    flex: 8,
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.05,
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.12,
                                        ),
                                        child: Container(
                                            width: constraints.maxWidth * 0.074,
                                            height:
                                                constraints.maxHeight * 0.183,
                                            child: Align(
                                              alignment: Alignment(0.00, 0.00),
                                              child: AutoSizeText(
                                                'Type',
                                                style: TextStyle(
                                                  fontFamily: 'Prompt',
                                                  fontSize: 10.0,
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
        ));
  }
}
