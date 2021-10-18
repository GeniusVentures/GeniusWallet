import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class MultChoice extends StatelessWidget {
  final constraints;
  final ovrType;
  final ovrTriangle;
  MultChoice(
    this.constraints, {
    Key key,
    this.ovrType,
    this.ovrTriangle,
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
        right: 57.0,
        top: constraints.maxHeight * 0.2,
        height: constraints.maxHeight * 0.6,
        child: Center(
            child: Container(
                height: 27.0,
                child: Container(
                    width: constraints.maxWidth * 243.000,
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
                    )))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.884,
        width: constraints.maxWidth * 0.065,
        top: constraints.maxHeight * 0.444,
        height: constraints.maxHeight * 0.2,
        child: Image.asset(
          ovrTriangle ?? 'assets/images/0_12530.png',
          width: constraints.maxWidth * 20.000,
          height: constraints.maxHeight * 9.000,
        ),
      ),
    ]);
  }
}
