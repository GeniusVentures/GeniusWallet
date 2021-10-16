import 'package:flutter/material.dart';
import './genius_icon.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Send extends StatelessWidget {
  final constraints;

  Send(
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
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 67,
                  child: Padding(
                      padding: EdgeInsets.only(),
                      child: Container(
                          width: constraints.maxWidth * 1.000,
                          height: constraints.maxHeight * 0.660,
                          child: Align(
                            alignment: Alignment(0.00, 0.00),
                            child: Stack(children: [
                              LayoutBuilder(builder: (context, constraints) {
                                return GeniusIcon(
                                  constraints,
                                );
                              }),
                              Positioned(
                                left: constraints.maxWidth * 0.268,
                                right: constraints.maxWidth * 0.268,
                                top: constraints.maxHeight * 0.236,
                                bottom: constraints.maxHeight * 0.271,
                                child: Image.asset(
                                  'assets/images/0_12471.png',
                                  width: constraints.maxWidth * 0.464,
                                  height: constraints.maxHeight * 0.153,
                                ),
                              ),
                            ]),
                          ))),
                ),
                Spacer(
                  flex: 11,
                ),
                Flexible(
                  flex: 24,
                  child: Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.18,
                        right: MediaQuery.of(context).size.width * 0.20,
                      ),
                      child: Container(
                          width: constraints.maxWidth * 0.623,
                          height: constraints.maxHeight * 0.236,
                          child: Align(
                            alignment: Alignment(0.00, 0.00),
                            child: AutoSizeText(
                              'Send',
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 13.0,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                letterSpacing: 0.0,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ))),
                ),
              ]),
        ));
  }
}
