// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/desktop/custom/support_button_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class SupportButton extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrSupport;
  final Widget? ovrMask;
  final Widget? ovrMask2;
  const SupportButton(
    this.constraints, {
    Key? key,
    this.ovrSupport,
    this.ovrMask,
    this.ovrMask2,
  }) : super(key: key);
  @override
  _SupportButton createState() => _SupportButton();
}

class _SupportButton extends State<SupportButton> {
  _SupportButton();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: SupportButtonCustom(
            child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: Stack(children: [
              Positioned(
                left: 0,
                width: widget.constraints.maxWidth * 1.0,
                top: 0,
                height: widget.constraints.maxHeight * 1.0,
                child: Container(
                  height: widget.constraints.maxHeight * 1.0,
                  width: widget.constraints.maxWidth * 1.0,
                  decoration: BoxDecoration(
                    color: Color(0xff2a2b31),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.365,
                width: widget.constraints.maxWidth * 0.469,
                top: widget.constraints.maxHeight * 0.286,
                height: widget.constraints.maxHeight * 0.4,
                child: Center(
                    child: Container(
                        height: 14.0,
                        width: widget.constraints.maxWidth * 0.46875,
                        child: AutoSizeText(
                          widget.ovrSupport ?? 'Support',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.30000001192092896,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ))),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.125,
                width: widget.constraints.maxWidth * 0.146,
                top: widget.constraints.maxHeight * 0.3,
                height: widget.constraints.maxHeight * 0.4,
                child: widget.ovrMask ??
                    Image.asset(
                      'assets/images/mask.png',
                      package: 'genius_wallet',
                      height: widget.constraints.maxHeight * 0.4,
                      width: widget.constraints.maxWidth * 0.14583333333333334,
                      fit: BoxFit.fill,
                    ),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.125,
                width: widget.constraints.maxWidth * 0.146,
                top: widget.constraints.maxHeight * 0.3,
                height: widget.constraints.maxHeight * 0.4,
                child: widget.ovrMask2 ??
                    Image.asset(
                      'assets/images/mask2.png',
                      package: 'genius_wallet',
                      height: widget.constraints.maxHeight * 0.4,
                      width: widget.constraints.maxWidth * 0.14583333333333334,
                      fit: BoxFit.fill,
                    ),
              ),
            ]),
          ),
        ])));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
