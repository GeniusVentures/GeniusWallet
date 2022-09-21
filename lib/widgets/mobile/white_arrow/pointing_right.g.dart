// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/mobile/custom/pointing_right_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PointingRight extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrWhiteArrowRight;
  const PointingRight(
    this.constraints, {
    Key? key,
    this.ovrWhiteArrowRight,
  }) : super(key: key);
  @override
  _PointingRight createState() => _PointingRight();
}

class _PointingRight extends State<PointingRight> {
  _PointingRight();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: PointingRightCustom(
            child: Stack(children: [
          Positioned(
            left: 0,
            width: 5.0,
            top: 0,
            height: 9.0,
            child: widget.ovrWhiteArrowRight ??
                SvgPicture.asset(
                  'assets/images/whitearrowright.svg',
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
