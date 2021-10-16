import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class HighlightedButton extends StatelessWidget {
  final constraints;
  final ovrReceive;
  HighlightedButton(
    this.constraints, {
    Key key,
    this.ovrReceive,
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
          width: constraints.maxWidth * 164.000,
          height: constraints.maxHeight * 23.000,
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
          width: constraints.maxWidth * 164.000,
          height: constraints.maxHeight * 23.000,
          decoration: BoxDecoration(
            color: Color(0xff3a3c43),
            borderRadius: BorderRadius.all(Radius.circular(14.0)),
            border: Border.all(
              color: Color(0xff7ac231),
              width: 2.0,
            ),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.341,
        width: constraints.maxWidth * 0.354,
        top: constraints.maxHeight * 0.13,
        height: constraints.maxHeight * 0.783,
        child: Center(
            child: Container(
                height: 18.0,
                child: Container(
                    width: constraints.maxWidth * 58.000,
                    height: constraints.maxHeight * 18.000,
                    child: AutoSizeText(
                      ovrReceive ?? 'Receive ',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )))),
      ),
    ]);
  }
}
