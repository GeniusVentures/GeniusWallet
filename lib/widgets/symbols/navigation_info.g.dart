import 'package:flutter/material.dart';
import 'package:geniuswallet/controller/tag/back_arrow_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class NavigationInfo extends StatelessWidget {
  final constraints;
  final ovri;
  final ovrEllipse;
  NavigationInfo(
    this.constraints, {
    Key key,
    this.ovri,
    this.ovrEllipse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: 0,
        width: 375.0,
        top: 0,
        height: 37.0,
        child: Container(
          width: constraints.maxWidth * 375.000,
          height: constraints.maxHeight * 37.000,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: 26.0,
        width: 10.0,
        top: 9.0,
        height: 18.0,
        child: BackArrowCustom(
            child: Image.asset(
          'assets/images/222_2932.png',
          width: constraints.maxWidth * 10.000,
          height: constraints.maxHeight * 18.000,
        )),
      ),
      Positioned(
        right: 21.0,
        width: 20.0,
        top: 7.0,
        height: 21.0,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: 20.0,
            top: 0,
            height: 21.0,
            child: Container(
              width: constraints.maxWidth * 20.000,
              height: constraints.maxHeight * 21.000,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            width: 20.0,
            top: 1.0,
            height: 20.0,
            child: Image.asset(
              ovrEllipse ?? 'assets/images/0_12072.png',
              width: constraints.maxWidth * 20.000,
              height: constraints.maxHeight * 20.000,
            ),
          ),
          Positioned(
            left: 8.0,
            width: 4.0,
            top: 0,
            height: 21.0,
            child: Container(
                width: constraints.maxWidth * 4.000,
                height: constraints.maxHeight * 21.000,
                child: AutoSizeText(
                  ovri ?? 'i',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    letterSpacing: 0.0,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                )),
          ),
        ]),
      ),
    ]);
  }
}
