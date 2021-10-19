import 'package:flutter/material.dart';
import 'package:geniuswallet/egg/geniuscheckboxcustom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class GeniusCheckbox extends StatelessWidget {
  final constraints;
  final ovrThePropertyofAutonomousVer;
  GeniusCheckbox(
    this.constraints, {
    Key key,
    this.ovrThePropertyofAutonomousVer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GeniusCheckboxCustom(
        child: Stack(children: [
      Positioned(
        left: 0,
        width: constraints.maxWidth * 1.0,
        top: 0,
        height: constraints.maxHeight * 0.952,
        child: Container(
          width: constraints.maxWidth * 308.000,
          height: constraints.maxHeight * 20.000,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: 0,
        width: 19.871,
        top: constraints.maxHeight * 0.087,
        height: constraints.maxHeight * 0.866,
        child: Center(
            child: Container(
                height: 18.18182373046875,
                child: Container(
                  width: constraints.maxWidth * 19.871,
                  height: constraints.maxHeight * 18.182,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    border: Border.all(
                      width: 2.0,
                    ),
                  ),
                ))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.094,
        width: constraints.maxWidth * 0.893,
        top: constraints.maxHeight * 0.238,
        height: constraints.maxHeight * 0.476,
        child: Container(
            width: constraints.maxWidth * 275.000,
            height: constraints.maxHeight * 10.000,
            child: AutoSizeText(
              ovrThePropertyofAutonomousVer ?? 'Type something',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 10.0,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.left,
            )),
      ),
    ]));
  }
}
