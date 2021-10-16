import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ShadedCard extends StatelessWidget {
  final constraints;

  ShadedCard(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: constraints.maxWidth * 1.000,
        height: constraints.maxHeight * 1.000,
        decoration: BoxDecoration(
          color: Color(0xff2a2b31),
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
          border: Border.all(
            color: Color(0xff979797),
          ),
        ),
        child: Align(
          alignment: Alignment(-0.07, -0.06),
          child: Container(
              width: constraints.maxWidth * 0.947,
              height: constraints.maxHeight * 0.514,
              child: Align(
                alignment: Alignment(0.00, 0.00),
                child: AutoSizeText(
                  '1Cs4wu6pu5qCZ35bSLNVzGyEx5N6uzbg9t',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    letterSpacing: 0.30000001192092896,
                    color: Color(0xff42434b),
                  ),
                  textAlign: TextAlign.left,
                ),
              )),
        ));
  }
}
