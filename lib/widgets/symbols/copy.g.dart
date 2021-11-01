import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/widgets/symbols/genius_icon.g.dart';

class Copy extends StatelessWidget {
  final constraints;
  final ovrIcon4;
  final ovrCopy;
  final ovrRectangle2Difference;
  Copy(
    this.constraints, {
    Key key,
    this.ovrIcon4,
    this.ovrCopy,
    this.ovrRectangle2Difference,
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
            ovrEllipse3: Image.asset(
              'assets/images/I0_12453;0_12263.png',
              width: constraints.maxWidth * 56.000,
              height: constraints.maxHeight * 56.000,
            ),
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
              ovrCopy ?? 'Copy',
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
        left: constraints.maxWidth * 0.395,
        width: constraints.maxWidth * 0.355,
        top: constraints.maxHeight * 0.251,
        height: constraints.maxHeight * 0.234,
        child: ovrRectangle2Difference ??
            Image.asset(
              'assets/images/0_12458.png',
              width: constraints.maxWidth * 19.875,
              height: constraints.maxHeight * 19.875,
            ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.268,
        width: constraints.maxWidth * 0.319,
        top: constraints.maxHeight * 0.167,
        height: constraints.maxHeight * 0.211,
        child: Container(
          width: constraints.maxWidth * 17.875,
          height: constraints.maxHeight * 17.875,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(2.0)),
            border: Border.all(
              color: Color(0xffffffff),
              width: 2.0,
            ),
          ),
        ),
      ),
    ]);
  }
}
