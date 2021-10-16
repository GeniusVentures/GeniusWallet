import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class MultChoice extends StatelessWidget {
  final constraints;

  MultChoice(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: constraints.maxWidth * 1.000,
        height: constraints.maxHeight * 1.000,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          border: Border.all(
            color: Color(0x00000000),
          ),
        ),
        child: Align(
          alignment: Alignment(-0.23, 0.00),
          child: Container(
              width: constraints.maxWidth * 0.916,
              height: constraints.maxHeight * 0.600,
              child: Align(
                alignment: Alignment(0.00, 0.00),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 86,
                        child: Padding(
                            padding: EdgeInsets.only(),
                            child: Container(
                                width: constraints.maxWidth * 0.784,
                                height: constraints.maxHeight * 0.600,
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
                                      color: Color(0xff575757),
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ))),
                      ),
                      Spacer(
                        flex: 8,
                      ),
                      Flexible(
                        flex: 8,
                        child: Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.height * 0.16,
                              top: MediaQuery.of(context).size.height * 0.24,
                            ),
                            child: Image.asset(
                              'assets/images/0_12530.png',
                              width: constraints.maxWidth * 0.065,
                              height: constraints.maxHeight * 0.200,
                            )),
                      )
                    ]),
              )),
        ));
  }
}
