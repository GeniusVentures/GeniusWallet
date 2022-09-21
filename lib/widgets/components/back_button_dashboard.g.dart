// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/back_button_dashboard_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BackButtonDashboard extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrBack;
  final Widget? ovrWhiteArrowLeft;
  const BackButtonDashboard(
    this.constraints, {
    Key? key,
    this.ovrBack,
    this.ovrWhiteArrowLeft,
  }) : super(key: key);
  @override
  _BackButtonDashboard createState() => _BackButtonDashboard();
}

class _BackButtonDashboard extends State<BackButtonDashboard> {
  _BackButtonDashboard();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: BackButtonDashboardCustom(
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
                left: widget.constraints.maxWidth * 0.354,
                width: widget.constraints.maxWidth * 0.494,
                top: widget.constraints.maxHeight * 0.286,
                height: widget.constraints.maxHeight * 0.4,
                child: Container(
                    height: widget.constraints.maxHeight * 0.4,
                    width: widget.constraints.maxWidth * 0.4936708860759494,
                    child: AutoSizeText(
                      widget.ovrBack ?? 'Back',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.139,
                width: widget.constraints.maxWidth * 0.063,
                top: widget.constraints.maxHeight * 0.371,
                height: widget.constraints.maxHeight * 0.257,
                child: widget.ovrWhiteArrowLeft ??
                    SvgPicture.asset(
                      'assets/images/whitearrowleft.svg',
                      package: 'genius_wallet',
                      height: widget.constraints.maxHeight * 0.2571428571428571,
                      width: widget.constraints.maxWidth * 0.06329113924050633,
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
