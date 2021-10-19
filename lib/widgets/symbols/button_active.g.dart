import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ButtonActive extends StatelessWidget {
  final constraints;
  final ovrTypesomething;
  ButtonActive(
    this.constraints, {
    Key key,
    this.ovrTypesomething,
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
          width: constraints.maxWidth * 310.000,
          height: constraints.maxHeight * 45.000,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.039,
        width: constraints.maxWidth * 0.923,
        top: constraints.maxHeight * 0.267,
        height: constraints.maxHeight * 0.467,
        child: Center(
            child: Container(
                height: 21.0,
                width: 285.999755859375,
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
                    )))),
      ),
    ]);
  }
}
