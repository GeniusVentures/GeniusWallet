import 'package:flutter/material.dart';
import 'package:geniuswallet/egg/menu.dart';
import 'package:geniuswallet/egg/bell.dart';

class NavigationMenu extends StatelessWidget {
  final constraints;

  NavigationMenu(
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
        left: 19.5,
        width: 16.5,
        top: 11.0,
        height: 12.0,
        child: Menu(
            child: Image.asset(
          'assets/images/110_4077.png',
          width: constraints.maxWidth * 16.500,
          height: constraints.maxHeight * 12.000,
        )),
      ),
      Positioned(
        right: 23.0,
        width: 15.5,
        top: 9.0,
        height: 19.0,
        child: Bell(
            child: Image.asset(
          'assets/images/166_1855.png',
          width: constraints.maxWidth * 15.500,
          height: constraints.maxHeight * 19.000,
        )),
      ),
    ]);
  }
}
