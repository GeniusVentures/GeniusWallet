import 'package:flutter/material.dart';
import 'package:geniuswallet/controller/tag/back_arrow_custom.dart';
import 'package:geniuswallet/controller/tag/buy.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/controller/tag/graph_custom.dart';

class NavigationBuy extends StatelessWidget {
  final constraints;

  NavigationBuy(
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
          'assets/images/222_2913.png',
          width: constraints.maxWidth * 10.000,
          height: constraints.maxHeight * 18.000,
        )),
      ),
      Positioned(
        right: 69.5,
        width: 26.0,
        top: constraints.maxHeight * 0.189,
        height: constraints.maxHeight * 0.568,
        child: Buy(
            child: AutoSizeText(
          'Buy',
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
      Positioned(
        right: 40.0,
        width: 16.0,
        top: 9.0,
        height: 16.0,
        child: GraphCustom(
            child: Image.asset(
          'assets/images/166_1933.png',
          width: constraints.maxWidth * 16.000,
          height: constraints.maxHeight * 16.000,
        )),
      ),
    ]);
  }
}
