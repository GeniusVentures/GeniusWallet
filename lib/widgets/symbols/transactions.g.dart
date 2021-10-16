import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Transactions extends StatelessWidget {
  final constraints;
  final ovrMask;
  final ovrMask2;
  final ovr1PRj85hu9RXPZTzxtko9;
  final ovr0009ETH;
  final ovr162312dec2018;
  Transactions(
    this.constraints, {
    Key key,
    this.ovrMask,
    this.ovrMask2,
    this.ovr1PRj85hu9RXPZTzxtko9,
    this.ovr0009ETH,
    this.ovr162312dec2018,
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
          width: constraints.maxWidth * 701.022,
          height: constraints.maxHeight * 71.716,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: 0,
        width: constraints.maxWidth * 1.0,
        top: 0,
        height: constraints.maxHeight * 1.0,
        child: Container(
          width: constraints.maxWidth * 701.022,
          height: constraints.maxHeight * 71.716,
          decoration: BoxDecoration(
            color: Color(0xff004abb),
            borderRadius: BorderRadius.all(Radius.circular(2.0)),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.034,
        width: constraints.maxWidth * 0.333,
        top: constraints.maxHeight * 0.194,
        height: constraints.maxHeight * 0.293,
        child: Center(
            child: Container(
                height: 21.0,
                child: Container(
                    width: constraints.maxWidth * 233.674,
                    height: constraints.maxHeight * 21.000,
                    child: AutoSizeText(
                      ovr162312dec2018 ?? '16:23, 12 dec 2018',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.25,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.758,
        width: constraints.maxWidth * 0.228,
        top: constraints.maxHeight * 0.162,
        height: constraints.maxHeight * 0.293,
        child: Center(
            child: Container(
                height: 21.0,
                child: Container(
                    width: constraints.maxWidth * 160.016,
                    height: constraints.maxHeight * 21.000,
                    child: AutoSizeText(
                      ovr0009ETH ?? '0.009 ETH',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.right,
                    )))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.034,
        width: constraints.maxWidth * 0.848,
        top: constraints.maxHeight * 0.499,
        height: constraints.maxHeight * 0.376,
        child: Center(
            child: Container(
                height: 27.0,
                child: Container(
                    width: constraints.maxWidth * 594.345,
                    height: constraints.maxHeight * 27.000,
                    child: AutoSizeText(
                      ovr1PRj85hu9RXPZTzxtko9 ??
                          '1PRj85hu9RXPZTzxtko9stfs6nRo1vyrQB',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.839,
        width: constraints.maxWidth * 0.024,
        top: constraints.maxHeight * 0.223,
        height: constraints.maxHeight * 0.153,
        child: Center(
            child: Container(
                height: 11.0,
                width: 17.0,
                child: Image.asset(
                  ovrMask2 ?? 'assets/images/0_12594.png',
                  width: constraints.maxWidth * 17.000,
                  height: constraints.maxHeight * 11.000,
                ))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.839,
        width: constraints.maxWidth * 0.024,
        top: constraints.maxHeight * 0.223,
        height: constraints.maxHeight * 0.153,
        child: Center(
            child: Container(
                height: 11.0,
                width: 17.0,
                child: Image.asset(
                  ovrMask ?? 'assets/images/0_12593.png',
                  width: constraints.maxWidth * 17.000,
                  height: constraints.maxHeight * 11.000,
                ))),
      ),
    ]);
  }
}
