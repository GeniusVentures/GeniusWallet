import 'package:flutter/material.dart';
import 'package:geniuswallet/egg/arrow.dart';
import 'package:geniuswallet/egg/next.dart';
import 'package:auto_size_text/auto_size_text.dart';

class NavigationNext extends StatelessWidget {
  final constraints;

  NavigationNext(
    this.constraints, {
    Key key,
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
        left: 29.0,
        width: 9.0,
        top: constraints.maxHeight * 0.27,
        height: constraints.maxHeight * 0.243,
        child: Center(
            child: Container(
                height: 9.0,
                child: Arrow(
                    child: Image.asset(
                  'assets/images/0_12087.png',
                  width: constraints.maxWidth * 9.000,
                  height: constraints.maxHeight * 9.000,
                )))),
      ),
      Positioned(
        right: 24.5,
        width: 32.0,
        top: constraints.maxHeight * 0.189,
        height: constraints.maxHeight * 0.568,
        child: Next(
            child: AutoSizeText(
          'Next',
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
    ]);
  }
}
