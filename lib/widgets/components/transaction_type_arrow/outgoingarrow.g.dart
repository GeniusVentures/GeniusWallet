// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Outgoingarrow extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrMaskArrow1;
  const Outgoingarrow(
    this.constraints, {
    Key? key,
    this.ovrMaskArrow1,
  }) : super(key: key);
  @override
  _Outgoingarrow createState() => _Outgoingarrow();
}

class _Outgoingarrow extends State<Outgoingarrow> {
  _Outgoingarrow();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: widget.constraints.maxHeight * 0.031,
            height: widget.constraints.maxHeight * 1.0,
            child: widget.ovrMaskArrow1 ??
                SvgPicture.asset(
                  'assets/images/maskarrow1.svg',
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
