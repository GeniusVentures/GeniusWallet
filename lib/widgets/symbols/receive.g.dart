import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/widgets/symbols/genius_icon.g.dart';

class Receive extends StatelessWidget {
  final constraints;
  final ovrIcon4;
  final ovrReceive;
  final ovrVector;
  Receive(
    this.constraints, {
    Key key,
    this.ovrIcon4,
    this.ovrReceive,
    this.ovrVector,
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
            ovrEllipse3: 'assets/images/I0_12476;0_12263.png',
          );
        }),
      ),
      Positioned(
        left: constraints.maxWidth * 0.036,
        width: constraints.maxWidth * 0.929,
        top: constraints.maxHeight * 0.769,
        height: constraints.maxHeight * 0.236,
        child: Container(
            width: constraints.maxWidth * 52.000,
            height: constraints.maxHeight * 20.000,
            child: AutoSizeText(
              ovrReceive ?? 'Receive',
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
        left: constraints.maxWidth * 0.27,
        width: constraints.maxWidth * 0.427,
        top: 23.0,
        height: 12.071,
        child: Center(
            child: Container(
                width: 23.8994140625,
                child: Image.asset(
                  ovrVector ?? 'assets/images/110_3428.png',
                  width: constraints.maxWidth * 23.899,
                  height: constraints.maxHeight * 12.071,
                ))),
      ),
    ]);
  }
}
