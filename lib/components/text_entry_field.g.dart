// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/components/custom/text_entry_field_logic.dart';
import 'package:genius_wallet/components/text_entry_field_widget.g.dart';

class TextEntryField extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrTextEntryHinthinttext;
  const TextEntryField(
    this.constraints, {
    Key? key,
    this.ovrTextEntryHinthinttext,
  }) : super(key: key);
  @override
  _TextEntryField createState() => _TextEntryField();
}

class _TextEntryField extends State<TextEntryField> {
  _TextEntryField();

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
            child: TextEntryFieldWidget(
              logic: TextEntryFieldLogic(context),
            ),
          ),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
