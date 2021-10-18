import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Alert extends StatelessWidget {
  final constraints;
  final ovrNeversharerecoveryphrasewi;
  Alert(
    this.constraints, {
    Key key,
    this.ovrNeversharerecoveryphrasewi,
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
          width: constraints.maxWidth * 311.000,
          height: constraints.maxHeight * 56.000,
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
          width: constraints.maxWidth * 311.000,
          height: constraints.maxHeight * 56.000,
          decoration: BoxDecoration(
            color: Color(0xff473234),
            borderRadius: BorderRadius.all(Radius.circular(9.0)),
          ),
        ),
      ),
      Positioned(
        left: 9.0,
        width: 27.0,
        top: 17.0,
        height: 22.0,
        child: Image.asset(
          'assets/images/0_12515.png',
          width: constraints.maxWidth * 27.000,
          height: constraints.maxHeight * 22.000,
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.145,
        width: constraints.maxWidth * 0.823,
        top: constraints.maxHeight * 0.179,
        height: constraints.maxHeight * 0.643,
        child: Container(
            width: constraints.maxWidth * 256.000,
            height: constraints.maxHeight * 36.000,
            child: AutoSizeText(
              ovrNeversharerecoveryphrasewi ??
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
            )),
      ),
    ]);
  }
}
