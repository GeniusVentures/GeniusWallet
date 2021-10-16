import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Words extends StatelessWidget {
  final constraints;
  final ovrWord;
  Words(
    this.constraints, {
    Key key,
    this.ovrWord,
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
          width: constraints.maxWidth * 51.300,
          height: constraints.maxHeight * 24.000,
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
          width: constraints.maxWidth * 51.300,
          height: constraints.maxHeight * 24.000,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(3.0)),
            border: Border.all(
              color: Color(0xff00efae),
              width: 1.0,
            ),
          ),
        ),
      ),
      Positioned(
        left: 5.3,
        right: 6.0,
        top: 8.0,
        bottom: 8.0,
        child: Container(
            width: constraints.maxWidth * 40.000,
            height: constraints.maxHeight * 8.000,
            child: AutoSizeText(
              ovrWord ?? 'Word',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 16.0,
                fontWeight: FontWeight.w300,
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
