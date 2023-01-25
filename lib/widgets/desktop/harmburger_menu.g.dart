// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/desktop/custom/harmburger_menu_custom.dart';

class HarmburgerMenu extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrMask;
  const HarmburgerMenu(
    this.constraints, {
    Key? key,
    this.ovrMask,
  }) : super(key: key);
  @override
  _HarmburgerMenu createState() => _HarmburgerMenu();
}

class _HarmburgerMenu extends State<HarmburgerMenu> {
  _HarmburgerMenu();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: HarmburgerMenuCustom(
            child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: widget.ovrMask ??
                Image.asset(
                  'assets/images/mask.png',
                  package: 'genius_wallet',
                  height: widget.constraints.maxHeight * 1.0,
                  width: widget.constraints.maxWidth * 1.0,
                  fit: BoxFit.fill,
                ),
          ),
        ])));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
