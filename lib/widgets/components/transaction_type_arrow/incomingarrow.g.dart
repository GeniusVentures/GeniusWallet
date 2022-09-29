// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Incomingarrow extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrMaskArrow2;
  const Incomingarrow(
    this.constraints, {
    Key? key,
    this.ovrMaskArrow2,
  }) : super(key: key);
  @override
  _Incomingarrow createState() => _Incomingarrow();
}

class _Incomingarrow extends State<Incomingarrow> {
  _Incomingarrow();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: widget.ovrMaskArrow2 ??
                SvgPicture.asset(
                  'assets/images/maskarrow2.svg',
                  package: 'genius_wallet',
                  height: widget.constraints.maxHeight * 1.0,
                  width: widget.constraints.maxWidth * 1.0,
                  fit: BoxFit.fill,
                ),
          ),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
