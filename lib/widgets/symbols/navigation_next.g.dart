import 'package:flutter/material.dart';
import 'package:geniuswallet/controller/tag/back_arrow_custom.dart';
import 'package:geniuswallet/controller/tag/next.dart';
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
        left: 26.0,
        width: 10.0,
        top: 9.0,
        height: 18.0,
        child: BackArrowCustom(
            child: Image.asset(
          'assets/images/222_2976.png',
          width: constraints.maxWidth * 10.000,
          height: constraints.maxHeight * 18.000,
        )),
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
