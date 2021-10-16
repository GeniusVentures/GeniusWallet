import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Alert extends StatelessWidget {
  final constraints;

  Alert(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: constraints.maxWidth * 1.000,
        height: constraints.maxHeight * 1.000,
        decoration: BoxDecoration(
          color: Color(0xff473234),
          borderRadius: BorderRadius.all(Radius.circular(9.0)),
          border: Border.all(
            color: Color(0x00000000),
          ),
        ),
        child: Align(
          alignment: Alignment(-0.05, 0.00),
          child: Container(
              width: constraints.maxWidth * 0.939,
              height: constraints.maxHeight * 0.643,
              child: Align(
                alignment: Alignment(0.00, 0.00),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 10,
                        child: Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.height * 0.13,
                              top: MediaQuery.of(context).size.height * 0.13,
                            ),
                            child: Image.asset(
                              'assets/images/0_12515.png',
                              width: constraints.maxWidth * 0.087,
                              height: constraints.maxHeight * 0.393,
                            )),
                      ),
                      Spacer(
                        flex: 4,
                      ),
                      Flexible(
                        flex: 88,
                        child: Padding(
                            padding: EdgeInsets.only(),
                            child: Container(
                                width: constraints.maxWidth * 0.823,
                                height: constraints.maxHeight * 0.643,
                                child: Align(
                                  alignment: Alignment(0.00, 0.00),
                                  child: AutoSizeText(
                                    'Never share recovery phrase with anyone, store it securely!',
                                    style: TextStyle(
                                      fontFamily: 'Prompt',
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                      letterSpacing: 0.0,
                                      color: Color(0xffda5656),
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ))),
                      )
                    ]),
              )),
        ));
  }
}
