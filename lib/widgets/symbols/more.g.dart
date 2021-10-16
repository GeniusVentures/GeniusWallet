import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/widgets/symbols/genius_icon.g.dart';

class More extends StatelessWidget {
  final constraints;
  final ovrIcon4;
  final ovrVector;
  final ovrMore;
  More(
    this.constraints, {
    Key key,
    this.ovrIcon4,
    this.ovrVector,
    this.ovrMore,
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
            ovrEllipse3: 'assets/images/I0_12444;0_12263.png',
          );
        }),
      ),
      Positioned(
        left: constraints.maxWidth * 0.23,
        width: constraints.maxWidth * 0.552,
        top: constraints.maxHeight * 0.304,
        height: constraints.maxHeight * 0.071,
        child: Image.asset(
          ovrVector ?? 'assets/images/176_1968.png',
          width: constraints.maxWidth * 30.888,
          height: constraints.maxHeight * 6.000,
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.179,
        width: constraints.maxWidth * 0.623,
        top: constraints.maxHeight * 0.764,
        height: constraints.maxHeight * 0.236,
        child: Center(
            child: Container(
                width: 34.90673828125,
                child: Container(
                    width: constraints.maxWidth * 34.907,
                    height: constraints.maxHeight * 20.000,
                    child: AutoSizeText(
                      ovrMore ?? 'More',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400,
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
