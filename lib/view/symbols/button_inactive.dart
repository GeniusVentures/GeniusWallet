import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ButtonInactive extends StatelessWidget {
  final constraints;

  ButtonInactive(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: constraints.maxWidth * 1.000,
        height: constraints.maxHeight * 1.000,
        decoration: BoxDecoration(
          color: Color(0xff808080),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          border: Border.all(
            color: Color(0x00000000),
          ),
        ),
        child: Align(
          alignment: Alignment(0.08, 0.00),
          child: Container(
              width: constraints.maxWidth * 0.923,
              height: constraints.maxHeight * 0.467,
              child: Align(
                alignment: Alignment(0.00, 0.00),
                child: AutoSizeText(
                  'Type something',
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
        ));
  }
}
