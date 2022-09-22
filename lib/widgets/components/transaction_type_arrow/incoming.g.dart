// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Incoming extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrMask;
  const Incoming(
    this.constraints, {
    Key? key,
    this.ovrMask,
  }) : super(key: key);
  @override
  _Incoming createState() => _Incoming();
}

class _Incoming extends State<Incoming> {
  _Incoming();

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
