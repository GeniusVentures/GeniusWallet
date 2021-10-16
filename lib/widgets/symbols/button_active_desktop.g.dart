import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ButtonActiveDesktop extends StatelessWidget {
  final constraints;
  final ovrNext;
  ButtonActiveDesktop(
    this.constraints, {
    Key key,
    this.ovrNext,
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
          width: constraints.maxWidth * 710.000,
          height: constraints.maxHeight * 64.000,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: Container(
          width: constraints.maxWidth * 710.000,
          height: constraints.maxHeight * 64.000,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
      Positioned(
        left: 153.4,
        right: 154.6,
        top: 14.0,
        bottom: 14.0,
        child: Container(
            width: constraints.maxWidth * 402.000,
            height: constraints.maxHeight * 36.000,
            child: AutoSizeText(
              ovrNext ?? 'Next',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 24.0,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
    ]);
  }
}
