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
        left: 29.0,
        width: 9.0,
        top: constraints.maxHeight * 0.27,
        height: constraints.maxHeight * 0.486,
        child: Center(
            child: Container(
                height: 18.0,
                child: BackArrow(
                    child: Image.asset(
                  'assets/images/0_12075.png',
                  width: constraints.maxWidth * 9.000,
                  height: constraints.maxHeight * 18.000,
                )))),
      ),
    ]);
  }
}
