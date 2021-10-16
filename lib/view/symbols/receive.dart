import 'package:flutter/material.dart';
import './genius_icon.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Receive extends StatelessWidget {
  final constraints;

  Receive(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: constraints.maxWidth * 1.000,
        height: constraints.maxHeight * 1.005,
        child: Align(
          alignment: Alignment(0.00, 0.00),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 66,
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
                                right: constraints.maxWidth * 0.500,
                                top: constraints.maxHeight * 0.271,
                                bottom: constraints.maxHeight * 0.236,
                                child: Image.asset(
                                  'assets/images/0_12478.png',
                                  width: constraints.maxWidth * 0.232,
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
                        left: MediaQuery.of(context).size.width * 0.04,
                        right: MediaQuery.of(context).size.width * 0.04,
                      ),
                      child: Container(
                          width: constraints.maxWidth * 0.929,
                          height: constraints.maxHeight * 0.236,
                          child: Align(
                            alignment: Alignment(0.00, 0.00),
                            child: AutoSizeText(
                              'Receive',
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
