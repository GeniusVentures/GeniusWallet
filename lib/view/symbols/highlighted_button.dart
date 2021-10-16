import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class HighlightedButton extends StatelessWidget {
  final constraints;

  HighlightedButton(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: constraints.maxWidth * 1.000,
        height: constraints.maxHeight * 1.000,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(14.0)),
          border: Border.all(
            color: Color(0xff7ac231),
          ),
        ),
        child: Align(
          alignment: Alignment(0.06, 0.20),
          child: Container(
              width: constraints.maxWidth * 0.354,
              height: constraints.maxHeight * 0.783,
              child: Align(
                alignment: Alignment(0.00, 0.00),
                child: AutoSizeText(
                  'Receive ',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    letterSpacing: 0.30000001192092896,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              )),
        ));
  }
}
