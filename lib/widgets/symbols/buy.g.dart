import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/widgets/symbols/genius_icon.g.dart';

class Buy extends StatelessWidget {
  final constraints;
  final ovrBuy;
  final ovrVector;
  final ovrIcon4;
  Buy(
    this.constraints, {
    Key key,
    this.ovrBuy,
    this.ovrVector,
    this.ovrIcon4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
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
        left: 0,
        width: constraints.maxWidth * 1.0,
        top: 0,
        height: constraints.maxHeight * 0.66,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: constraints.maxWidth * 1.0,
            top: 0,
            height: constraints.maxHeight * 0.66,
            child: Container(
              width: constraints.maxWidth * 56.000,
              height: constraints.maxHeight * 56.000,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
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
            left: constraints.maxWidth * 0.232,
            width: constraints.maxWidth * 0.553,
            top: constraints.maxHeight * 0.153,
            height: constraints.maxHeight * 0.365,
            child: Center(
                child: Container(
                    height: 30.991378784179688,
                    width: 30.991455078125,
                    child: Image.asset(
                      ovrVector ?? 'assets/images/222_3028.png',
                      width: constraints.maxWidth * 30.991,
                      height: constraints.maxHeight * 30.991,
                    ))),
          ),
        ]),
      ),
    ]);
  }
}
