import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/widgets/symbols/genius_icon.g.dart';

class Send extends StatelessWidget {
  final constraints;
  final ovrIcon4;
  final ovrSend;
  Send(
    this.constraints, {
    Key key,
    this.ovrIcon4,
    this.ovrSend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: 0,
        width: constraints.maxWidth * 1.0,
        top: 0,
        height: constraints.maxHeight * 0.66,
        child: LayoutBuilder(builder: (context, constraints) {
          return GeniusIcon(
            constraints,
            ovrEllipse3: 'assets/images/I0_12469;0_12263.png',
          );
        }),
      ),
      Positioned(
        left: constraints.maxWidth * 0.179,
        width: constraints.maxWidth * 0.623,
        top: constraints.maxHeight * 0.764,
        height: constraints.maxHeight * 0.236,
        child: Container(
            width: constraints.maxWidth * 34.907,
            height: constraints.maxHeight * 20.000,
            child: AutoSizeText(
              ovrSend ?? 'Send',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 13.0,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
      Positioned(
        left: constraints.maxWidth * 0.268,
        width: constraints.maxWidth * 0.464,
        top: 21.0,
        height: 13.0,
        child: Center(
            child: Container(
                width: 26.0,
                child: Image.asset(
                  'assets/images/0_12471.png',
                  width: constraints.maxWidth * 26.000,
                  height: constraints.maxHeight * 13.000,
                ))),
      ),
    ]);
  }
}
