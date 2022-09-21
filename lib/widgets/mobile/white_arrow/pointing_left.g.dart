// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/mobile/custom/pointing_left_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PointingLeft extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrWhiteArrowLeft;
  const PointingLeft(
    this.constraints, {
    Key? key,
    this.ovrWhiteArrowLeft,
  }) : super(key: key);
  @override
  _PointingLeft createState() => _PointingLeft();
}

class _PointingLeft extends State<PointingLeft> {
  _PointingLeft();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: PointingLeftCustom(
            child: Stack(children: [
          Positioned(
            left: 0,
            width: 5.0,
            top: 0,
            height: 9.0,
            child: widget.ovrWhiteArrowLeft ??
                SvgPicture.asset(
                  'assets/images/whitearrowleft.svg',
                  package: 'genius_wallet',
                  height: 9.0,
                  width: 5.0,
                  fit: BoxFit.none,
                ),
          ),
        ])));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
