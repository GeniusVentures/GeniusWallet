// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/dd_wallet_text_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class DdWalletText extends StatefulWidget {
  final BoxConstraints constraints;

  const DdWalletText(
    this.constraints, {
    Key? key,
  }) : super(key: key);
  @override
  _DdWalletText createState() => _DdWalletText();
}

class _DdWalletText extends State<DdWalletText> {
  _DdWalletText();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: DdWalletTextCustom(
            child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: DdWalletTextCustom(
                child: AutoSizeText(
              ' Аdd wallet ',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.30000001192092896,
                color: Color(0xff7ac231),
              ),
              textAlign: TextAlign.center,
            )),
          ),
        ])));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
