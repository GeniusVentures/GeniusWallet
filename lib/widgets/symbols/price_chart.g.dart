import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class PriceChart extends StatelessWidget {
  final constraints;
  final ovrPath4;
  final ovr1jan;
  final ovr18dec;
  final ovr4dec;
  final ovr20nov;
  final ovr6nov;
  final ovr23oct;
  final ovr0k;
  final ovr5k;
  final ovr10k;
  final ovr20k;
  final ovr15k;
  final ovrAll;
  final ovr1y;
  final ovr6m;
  final ovr3m;
  final ovr1m;
  final ovrEthereumChart;
  PriceChart(
    this.constraints, {
    Key key,
    this.ovrPath4,
    this.ovr1jan,
    this.ovr18dec,
    this.ovr4dec,
    this.ovr20nov,
    this.ovr6nov,
    this.ovr23oct,
    this.ovr0k,
    this.ovr5k,
    this.ovr10k,
    this.ovr20k,
    this.ovr15k,
    this.ovrAll,
    this.ovr1y,
    this.ovr6m,
    this.ovr3m,
    this.ovr1m,
    this.ovrEthereumChart,
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
          width: constraints.maxWidth * 795.000,
          height: constraints.maxHeight * 362.000,
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
          width: constraints.maxWidth * 795.000,
          height: constraints.maxHeight * 362.000,
          decoration: BoxDecoration(
            color: Color(0xff003698),
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.037,
        width: constraints.maxWidth * 0.237,
        top: constraints.maxHeight * 0.065,
        height: constraints.maxHeight * 0.083,
        child: Center(
            child: Container(
                height: 30.0,
                child: Container(
                    width: constraints.maxWidth * 188.706,
                    height: constraints.maxHeight * 30.000,
                    child: AutoSizeText(
                      ovrEthereumChart ?? 'Ethereum Chart',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.752,
        width: constraints.maxWidth * 0.057,
        top: constraints.maxHeight * 0.092,
        height: constraints.maxHeight * 0.055,
        child: Container(
          width: constraints.maxWidth * 45.046,
          height: constraints.maxHeight * 20.000,
          decoration: BoxDecoration(
            color: Color(0xff004abb),
            borderRadius: BorderRadius.all(Radius.circular(14.0)),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.713,
        width: constraints.maxWidth * 0.025,
        top: constraints.maxHeight * 0.093,
        height: constraints.maxHeight * 0.05,
        child: Center(
            child: Container(
                height: 18.0,
                child: Container(
                    width: constraints.maxWidth * 19.479,
                    height: constraints.maxHeight * 18.000,
                    child: AutoSizeText(
                      ovr1m ?? '1m',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.766,
        width: constraints.maxWidth * 0.028,
        top: constraints.maxHeight * 0.093,
        height: constraints.maxHeight * 0.05,
        child: Center(
            child: Container(
                height: 18.0,
                child: Container(
                    width: constraints.maxWidth * 21.914,
                    height: constraints.maxHeight * 18.000,
                    child: AutoSizeText(
                      ovr3m ?? '3m',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.822,
        width: constraints.maxWidth * 0.028,
        top: constraints.maxHeight * 0.093,
        height: constraints.maxHeight * 0.05,
        child: Center(
            child: Container(
                height: 18.0,
                child: Container(
                    width: constraints.maxWidth * 21.914,
                    height: constraints.maxHeight * 18.000,
                    child: AutoSizeText(
                      ovr6m ?? '6m',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.878,
        width: constraints.maxWidth * 0.018,
        top: constraints.maxHeight * 0.093,
        height: constraints.maxHeight * 0.05,
        child: Center(
            child: Container(
                height: 18.0,
                child: Container(
                    width: constraints.maxWidth * 14.609,
                    height: constraints.maxHeight * 18.000,
                    child: AutoSizeText(
                      ovr1y ?? '1y',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.927,
        width: constraints.maxWidth * 0.025,
        top: constraints.maxHeight * 0.093,
        height: constraints.maxHeight * 0.05,
        child: Center(
            child: Container(
                height: 18.0,
                child: Container(
                    width: constraints.maxWidth * 19.479,
                    height: constraints.maxHeight * 18.000,
                    child: AutoSizeText(
                      ovrAll ?? 'All',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.037,
        width: constraints.maxWidth * 0.06,
        top: constraints.maxHeight * 0.378,
        height: constraints.maxHeight * 0.033,
        child: Center(
            child: Container(
                height: 12.0,
                child: Container(
                    width: constraints.maxWidth * 47.481,
                    height: constraints.maxHeight * 12.000,
                    child: AutoSizeText(
                      ovr15k ?? '15k',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 10.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.25,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.037,
        width: constraints.maxWidth * 0.06,
        top: constraints.maxHeight * 0.259,
        height: constraints.maxHeight * 0.033,
        child: Center(
            child: Container(
                height: 12.0,
                child: Container(
                    width: constraints.maxWidth * 47.481,
                    height: constraints.maxHeight * 12.000,
                    child: AutoSizeText(
                      ovr20k ?? '20k',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 10.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.25,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.037,
        width: constraints.maxWidth * 0.06,
        top: constraints.maxHeight * 0.498,
        height: constraints.maxHeight * 0.033,
        child: Center(
            child: Container(
                height: 12.0,
                child: Container(
                    width: constraints.maxWidth * 47.481,
                    height: constraints.maxHeight * 12.000,
                    child: AutoSizeText(
                      ovr10k ?? '10k',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 10.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.25,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.037,
        width: constraints.maxWidth * 0.06,
        top: constraints.maxHeight * 0.618,
        height: constraints.maxHeight * 0.033,
        child: Center(
            child: Container(
                height: 12.0,
                child: Container(
                    width: constraints.maxWidth * 47.481,
                    height: constraints.maxHeight * 12.000,
                    child: AutoSizeText(
                      ovr5k ?? '5k',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 10.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.25,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.037,
        width: constraints.maxWidth * 0.06,
        top: constraints.maxHeight * 0.737,
        height: constraints.maxHeight * 0.033,
        child: Center(
            child: Container(
                height: 12.0,
                child: Container(
                    width: constraints.maxWidth * 47.481,
                    height: constraints.maxHeight * 12.000,
                    child: AutoSizeText(
                      ovr0k ?? '0k',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 10.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.25,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.136,
        width: constraints.maxWidth * 0.06,
        top: constraints.maxHeight * 0.846,
        height: constraints.maxHeight * 0.033,
        child: Center(
            child: Container(
                height: 12.0,
                child: Container(
                    width: constraints.maxWidth * 47.481,
                    height: constraints.maxHeight * 12.000,
                    child: AutoSizeText(
                      ovr23oct ?? '23 oct',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 10.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.25,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.289,
        width: constraints.maxWidth * 0.06,
        top: constraints.maxHeight * 0.846,
        height: constraints.maxHeight * 0.033,
        child: Center(
            child: Container(
                height: 12.0,
                child: Container(
                    width: constraints.maxWidth * 47.481,
                    height: constraints.maxHeight * 12.000,
                    child: AutoSizeText(
                      ovr6nov ?? '6 nov',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 10.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.25,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.443,
        width: constraints.maxWidth * 0.06,
        top: constraints.maxHeight * 0.846,
        height: constraints.maxHeight * 0.033,
        child: Center(
            child: Container(
                height: 12.0,
                child: Container(
                    width: constraints.maxWidth * 47.481,
                    height: constraints.maxHeight * 12.000,
                    child: AutoSizeText(
                      ovr20nov ?? '20 nov',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 10.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.25,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.596,
        width: constraints.maxWidth * 0.06,
        top: constraints.maxHeight * 0.846,
        height: constraints.maxHeight * 0.033,
        child: Center(
            child: Container(
                height: 12.0,
                child: Container(
                    width: constraints.maxWidth * 47.481,
                    height: constraints.maxHeight * 12.000,
                    child: AutoSizeText(
                      ovr4dec ?? '4 dec',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 10.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.25,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.749,
        width: constraints.maxWidth * 0.06,
        top: constraints.maxHeight * 0.846,
        height: constraints.maxHeight * 0.033,
        child: Center(
            child: Container(
                height: 12.0,
                child: Container(
                    width: constraints.maxWidth * 47.481,
                    height: constraints.maxHeight * 12.000,
                    child: AutoSizeText(
                      ovr18dec ?? '18 dec',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 10.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.25,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.902,
        width: constraints.maxWidth * 0.06,
        top: constraints.maxHeight * 0.846,
        height: constraints.maxHeight * 0.033,
        child: Center(
            child: Container(
                height: 12.0,
                child: Container(
                    width: constraints.maxWidth * 47.481,
                    height: constraints.maxHeight * 12.000,
                    child: AutoSizeText(
                      ovr1jan ?? '1 jan',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 10.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.25,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )))),
      ),
      Positioned(
        left: constraints.maxWidth * 0.123,
        width: constraints.maxWidth * 0.825,
        top: constraints.maxHeight * 0.281,
        height: constraints.maxHeight * 0.003,
        child: Container(
          width: constraints.maxWidth * 656.210,
          height: constraints.maxHeight * 1.157,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.123,
        width: constraints.maxWidth * 0.825,
        top: constraints.maxHeight * 0.4,
        height: constraints.maxHeight * 0.003,
        child: Container(
          width: constraints.maxWidth * 656.210,
          height: constraints.maxHeight * 1.156,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.123,
        width: constraints.maxWidth * 0.825,
        top: constraints.maxHeight * 0.519,
        height: constraints.maxHeight * 0.003,
        child: Container(
          width: constraints.maxWidth * 656.210,
          height: constraints.maxHeight * 1.156,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.123,
        width: constraints.maxWidth * 0.825,
        top: constraints.maxHeight * 0.638,
        height: constraints.maxHeight * 0.003,
        child: Container(
          width: constraints.maxWidth * 656.210,
          height: constraints.maxHeight * 1.156,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.123,
        width: constraints.maxWidth * 0.825,
        top: constraints.maxHeight * 0.757,
        height: constraints.maxHeight * 0.003,
        child: Container(
          width: constraints.maxWidth * 656.210,
          height: constraints.maxHeight * 1.156,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.159,
        width: constraints.maxWidth * 0.002,
        top: constraints.maxHeight * 0.76,
        height: constraints.maxHeight * 0.013,
        child: Container(
          width: constraints.maxWidth * 1.217,
          height: constraints.maxHeight * 4.626,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.315,
        width: constraints.maxWidth * 0.002,
        top: constraints.maxHeight * 0.76,
        height: constraints.maxHeight * 0.013,
        child: Container(
          width: constraints.maxWidth * 1.217,
          height: constraints.maxHeight * 4.626,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.47,
        width: constraints.maxWidth * 0.002,
        top: constraints.maxHeight * 0.76,
        height: constraints.maxHeight * 0.013,
        child: Container(
          width: constraints.maxWidth * 1.217,
          height: constraints.maxHeight * 4.626,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.625,
        width: constraints.maxWidth * 0.002,
        top: constraints.maxHeight * 0.76,
        height: constraints.maxHeight * 0.013,
        child: Container(
          width: constraints.maxWidth * 1.217,
          height: constraints.maxHeight * 4.626,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.78,
        width: constraints.maxWidth * 0.002,
        top: constraints.maxHeight * 0.76,
        height: constraints.maxHeight * 0.013,
        child: Container(
          width: constraints.maxWidth * 1.217,
          height: constraints.maxHeight * 4.626,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.936,
        width: constraints.maxWidth * 0.002,
        top: constraints.maxHeight * 0.76,
        height: constraints.maxHeight * 0.013,
        child: Container(
          width: constraints.maxWidth * 1.217,
          height: constraints.maxHeight * 4.626,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.127,
        width: constraints.maxWidth * 0.821,
        top: constraints.maxHeight * 0.367,
        height: constraints.maxHeight * 0.342,
        child: Image.asset(
          ovrPath4 ?? 'assets/images/0_12639.png',
          width: constraints.maxWidth * 652.558,
          height: constraints.maxHeight * 123.751,
        ),
      ),
    ]);
  }
}
