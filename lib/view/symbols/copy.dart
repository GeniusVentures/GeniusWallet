import 'package:flutter/material.dart';
import './genius_icon.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Copy extends StatelessWidget {
  final constraints;

  Copy(
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
                                right: constraints.maxWidth * 0.413,
                                top: constraints.maxHeight * 0.167,
                                bottom: constraints.maxHeight * 0.282,
                                child: Container(
                                  width: constraints.maxWidth * 0.319,
                                  height: constraints.maxHeight * 0.211,
                                  decoration: BoxDecoration(
                                    color: Color(0x00000000),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(2.0)),
                                    border: Border.all(
                                      color: Color(0xffffffff),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: constraints.maxWidth * 0.395,
                                right: constraints.maxWidth * 0.250,
                                top: constraints.maxHeight * 0.251,
                                bottom: constraints.maxHeight * 0.175,
                                child: Image.asset(
                                  'assets/images/0_12458.png',
                                  width: constraints.maxWidth * 0.355,
                                  height: constraints.maxHeight * 0.234,
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
                              'Copy',
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
