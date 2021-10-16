import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ShadedCard extends StatelessWidget {
  final constraints;
  final ovrTokenAddress;
  ShadedCard(
    this.constraints, {
    Key key,
    this.ovrTokenAddress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: 0,
        width: constraints.maxWidth * 1.0,
        top: 0,
        height: constraints.maxHeight * 1.0,
        child: Container(
          width: constraints.maxWidth * 282.000,
          height: constraints.maxHeight * 35.000,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: 0,
        width: constraints.maxWidth * 1.0,
        top: 0,
        height: constraints.maxHeight * 1.0,
        child: Container(
          width: constraints.maxWidth * 282.000,
          height: constraints.maxHeight * 35.000,
          decoration: BoxDecoration(
            color: Color(0xff2a2b31),
            borderRadius: BorderRadius.all(Radius.circular(2.0)),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.025,
        width: constraints.maxWidth * 0.947,
        top: constraints.maxHeight * 0.229,
        height: constraints.maxHeight * 0.514,
        child: Center(
            child: Container(
                height: 18.0,
                child: Container(
                    width: constraints.maxWidth * 267.000,
                    height: constraints.maxHeight * 18.000,
                    child: AutoSizeText(
                      ovrTokenAddress ?? '1Cs4wu6pu5qCZ35bSLNVzGyEx5N6uzbg9t',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.30000001192092896,
                        color: Color(0xff42434b),
                      ),
                      textAlign: TextAlign.left,
                    )))),
      ),
    ]);
  }
}
