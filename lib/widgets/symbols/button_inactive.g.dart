import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ButtonInactive extends StatelessWidget {
  final constraints;
  final ovrTypesomething;
  ButtonInactive(
    this.constraints, {
    Key key,
    this.ovrTypesomething,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: Container(
          width: constraints.maxWidth * 310.000,
          height: constraints.maxHeight * 45.000,
          decoration: BoxDecoration(
            color: Color(0xff808080),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
      Positioned(
        left: 13.0,
        right: 11.0,
        top: 12.0,
        bottom: 12.0,
        child: Container(
            width: constraints.maxWidth * 286.000,
            height: constraints.maxHeight * 21.000,
            child: AutoSizeText(
              ovrTypesomething ?? 'Type something',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 14.0,
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
