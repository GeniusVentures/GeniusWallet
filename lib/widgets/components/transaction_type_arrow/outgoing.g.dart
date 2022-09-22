// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Outgoing extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrMask;
  const Outgoing(
    this.constraints, {
    Key? key,
    this.ovrMask,
  }) : super(key: key);
  @override
  _Outgoing createState() => _Outgoing();
}

class _Outgoing extends State<Outgoing> {
  _Outgoing();

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
            child: widget.ovrMask ??
                SvgPicture.asset(
                  'assets/images/mask.svg',
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
