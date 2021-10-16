import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CoverBuyCryptoDesktop extends StatelessWidget {
  final constraints;

  CoverBuyCryptoDesktop(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: constraints.maxWidth * 0.896,
        height: constraints.maxHeight * 0.618,
        child: Align(
          alignment: Alignment(0.00, 0.00),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 16,
                  child: Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.11,
                        right: MediaQuery.of(context).size.width * 0.11,
                      ),
                      child: Container(
                          width: constraints.maxWidth * 0.670,
                          height: constraints.maxHeight * 0.096,
                          child: Align(
                            alignment: Alignment(0.00, 0.00),
                            child: AutoSizeText(
                              'Title',
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
                  flex: 25,
                ),
                Flexible(
                  flex: 60,
                  child: Padding(
                      padding: EdgeInsets.only(),
                      child: Container(
                          width: constraints.maxWidth * 0.896,
                          height: constraints.maxHeight * 0.369,
                          child: Align(
                            alignment: Alignment(0.00, 0.00),
                            child: Stack(children: [
                              Positioned(
                                left: constraints.maxWidth * 0.000,
                                right: constraints.maxWidth * 0.000,
                                top: constraints.maxHeight * 0.000,
                                bottom: constraints.maxHeight * 0.056,
                                child: Container(
                                    width: constraints.maxWidth * 0.896,
                                    height: constraints.maxHeight * 0.313,
                                    child: Align(
                                      alignment: Alignment(0.00, 0.00),
                                      child: AutoSizeText(
                                        'Amount',
                                        style: TextStyle(
                                          fontFamily: 'Prompt',
                                          fontSize: 48.0,
                                          fontWeight: FontWeight.w700,
                                          fontStyle: FontStyle.normal,
                                          letterSpacing: 0.0,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    )),
                              ),
                              Positioned(
                                left: constraints.maxWidth * 0.000,
                                right: constraints.maxWidth * 0.000,
                                top: constraints.maxHeight * 0.266,
                                bottom: constraints.maxHeight * 0.000,
                                child: Container(
                                    width: constraints.maxWidth * 0.896,
                                    height: constraints.maxHeight * 0.103,
                                    child: Align(
                                      alignment: Alignment(0.00, 0.00),
                                      child: AutoSizeText(
                                        'Text',
                                        style: TextStyle(
                                          fontFamily: 'Prompt',
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w100,
                                          fontStyle: FontStyle.normal,
                                          letterSpacing: 0.0,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    )),
                              ),
                            ]),
                          ))),
                ),
              ]),
        ));
  }
}
