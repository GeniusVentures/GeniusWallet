import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class TextInput extends StatelessWidget {
  final constraints;
  final ovrType;
  TextInput(
    this.constraints, {
    Key key,
    this.ovrType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: 0,
        right: 0,
        top: 0,
        height: constraints.maxHeight * 1.0,
        child: Container(
          width: constraints.maxWidth * 310.000,
          height: constraints.maxHeight * 45.000,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
      Positioned(
        left: 10.0,
        right: 9.0,
        top: 9.0,
        height: 27.0,
        child: Container(
            width: constraints.maxWidth * 291.000,
            height: constraints.maxHeight * 27.000,
            child: AutoSizeText(
              ovrType ?? 'Type',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Color(0xff575757),
              ),
              textAlign: TextAlign.left,
            )),
      ),
    ]);
  }
}
