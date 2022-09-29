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

  const PasscodeEntry(
    this.constraints, {
    Key? key,
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
            width: widget.constraints.maxWidth * 0.085,
            bottom: 0,
            height: 2.0,
            child: Center(
                child: Container(
                    height: 2.0,
                    width: 27.0,
                    child: SvgPicture.asset(
                      'assets/images/passcodeframe.svg',
                      package: 'genius_wallet',
                      height: 2.0,
                      width: 27.0,
                      fit: BoxFit.scaleDown,
                    ))),
          ),
        ])));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
