// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/genius_back_button_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GeniusBackButton extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrWhiteArrowBack;
  const GeniusBackButton(
    this.constraints, {
    Key? key,
    this.ovrWhiteArrowBack,
  }) : super(key: key);
  @override
  _GeniusBackButton createState() => _GeniusBackButton();
}

class _GeniusBackButton extends State<GeniusBackButton> {
  _GeniusBackButton();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: GeniusBackButtonCustom(
            child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: widget.ovrWhiteArrowBack ??
                SvgPicture.asset(
                  'assets/images/whitearrowback.svg',
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
