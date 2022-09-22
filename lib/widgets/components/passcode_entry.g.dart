// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/passcode_entry_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PasscodeEntry extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrLine6;
  final Widget? ovrLine7;
  final Widget? ovrLine8;
  final Widget? ovrLine9;
  final Widget? ovrLine10;
  final Widget? ovrLine11;
  const PasscodeEntry(
    this.constraints, {
    Key? key,
    this.ovrLine6,
    this.ovrLine7,
    this.ovrLine8,
    this.ovrLine9,
    this.ovrLine10,
    this.ovrLine11,
  }) : super(key: key);
  @override
  _PasscodeEntry createState() => _PasscodeEntry();
}

class _PasscodeEntry extends State<PasscodeEntry> {
  _PasscodeEntry();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: PasscodeEntryCustom(
            child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: Stack(children: [
              Positioned(
                left: 0,
                width: 27.0,
                top: 48.0,
                height: 2.0,
                child: widget.ovrLine6 ??
                    SvgPicture.asset(
                      'assets/images/line6.svg',
                      package: 'genius_wallet',
                      height: 2.0,
                      width: 27.0,
                      fit: BoxFit.none,
                    ),
              ),
              Positioned(
                left: 58.0,
                width: 27.0,
                top: 48.0,
                height: 2.0,
                child: widget.ovrLine7 ??
                    SvgPicture.asset(
                      'assets/images/line7.svg',
                      package: 'genius_wallet',
                      height: 2.0,
                      width: 27.0,
                      fit: BoxFit.none,
                    ),
              ),
              Positioned(
                left: 116.0,
                width: 27.0,
                top: 48.0,
                height: 2.0,
                child: widget.ovrLine8 ??
                    SvgPicture.asset(
                      'assets/images/line8.svg',
                      package: 'genius_wallet',
                      height: 2.0,
                      width: 27.0,
                      fit: BoxFit.none,
                    ),
              ),
              Positioned(
                left: 174.0,
                width: 27.0,
                top: 48.0,
                height: 2.0,
                child: widget.ovrLine9 ??
                    SvgPicture.asset(
                      'assets/images/line9.svg',
                      package: 'genius_wallet',
                      height: 2.0,
                      width: 27.0,
                      fit: BoxFit.none,
                    ),
              ),
              Positioned(
                left: 232.0,
                width: 27.0,
                top: 48.0,
                height: 2.0,
                child: widget.ovrLine10 ??
                    SvgPicture.asset(
                      'assets/images/line10.svg',
                      package: 'genius_wallet',
                      height: 2.0,
                      width: 27.0,
                      fit: BoxFit.none,
                    ),
              ),
              Positioned(
                left: 290.0,
                width: 27.0,
                top: 48.0,
                height: 2.0,
                child: widget.ovrLine11 ??
                    SvgPicture.asset(
                      'assets/images/line11.svg',
                      package: 'genius_wallet',
                      height: 2.0,
                      width: 27.0,
                      fit: BoxFit.none,
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
