import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/widgets/symbols/genius_icon.g.dart';

class Buy extends StatelessWidget {
  final constraints;
  final ovrIcon4;
  final ovrBuy;
  Buy(
    this.constraints, {
    Key key,
    this.ovrIcon4,
    this.ovrBuy,
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
            ovrEllipse3: 'assets/images/I0_12462;0_12263.png',
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
              ovrBuy ?? 'Buy',
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
        left: 10.0,
        width: 36.736,
        top: 10.0,
        height: 36.736,
        child: Image.asset(
          'assets/images/0_12464.png',
          width: constraints.maxWidth * 36.736,
          height: constraints.maxHeight * 36.736,
        ),
      ),
    ]);
  }
}
