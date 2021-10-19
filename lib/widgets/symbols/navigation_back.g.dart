import 'package:flutter/material.dart';
import 'package:geniuswallet/egg/backarrow.dart';

class NavigationBack extends StatelessWidget {
  final constraints;

  NavigationBack(
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
        left: constraints.maxWidth * 0.069,
        width: constraints.maxWidth * 0.027,
        top: constraints.maxHeight * 0.243,
        height: constraints.maxHeight * 0.486,
        child: BackArrow(
            child: Image.asset(
          'assets/images/222_2766.png',
          width: constraints.maxWidth * 10.000,
          height: constraints.maxHeight * 18.000,
        )),
      ),
    ]);
  }
}
