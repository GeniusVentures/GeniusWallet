import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class NavigationInfo extends StatelessWidget {
  final constraints;

  NavigationInfo(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: constraints.maxWidth * 0.867,
        height: constraints.maxHeight * 0.568,
        child: Align(
          alignment: Alignment(0.00, 0.00),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  flex: 7,
                  child: Padding(
                      padding: EdgeInsets.only(),
                      child: Container(
                          width: constraints.maxWidth * 0.053,
                          height: constraints.maxHeight * 0.568,
                          child: Align(
                            alignment: Alignment(0.00, 0.00),
                            child: Stack(children: [
                              Positioned(
                                left: constraints.maxWidth * 0.000,
                                right: constraints.maxWidth * 0.000,
                                top: constraints.maxHeight * 0.027,
                                bottom: constraints.maxHeight * 0.000,
                                child: Image.asset(
                                  'assets/images/0_12072.png',
                                  width: constraints.maxWidth * 0.053,
                                  height: constraints.maxHeight * 0.541,
                                ),
                              ),
                              Positioned(
                                left: constraints.maxWidth * 0.021,
                                right: constraints.maxWidth * 0.021,
                                top: constraints.maxHeight * 0.000,
                                bottom: constraints.maxHeight * 0.000,
                                child: Container(
                                    width: constraints.maxWidth * 0.011,
                                    height: constraints.maxHeight * 0.568,
                                    child: Align(
                                      alignment: Alignment(0.00, 0.00),
                                      child: AutoSizeText(
                                        'i',
                                        style: TextStyle(
                                          fontFamily: 'Prompt',
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w500,
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
                Flexible(
                  flex: 3,
                  child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height * 0.24,
                        top: MediaQuery.of(context).size.height * 0.08,
                      ),
                      child: Image.asset(
                        'assets/images/0_12068.png',
                        width: constraints.maxWidth * 0.024,
                        height: constraints.maxHeight * 0.243,
                      )),
                )
              ]),
        ));
  }
}
