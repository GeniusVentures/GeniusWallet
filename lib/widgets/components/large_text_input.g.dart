// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/large_text_input_logic.dart';
import 'package:genius_wallet/widgets/components/large_text_input_widget.g.dart';

class LargeTextInput extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrLargeTextInputHinthinttext;
  const LargeTextInput(
    this.constraints, {
    Key? key,
    this.ovrLargeTextInputHinthinttext,
  }) : super(key: key);
  @override
  _LargeTextInput createState() => _LargeTextInput();
}

class _LargeTextInput extends State<LargeTextInput> {
  _LargeTextInput();

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
            child: LargeTextInputWidget(),
          ),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
