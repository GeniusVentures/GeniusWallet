// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/save_button_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class SaveButton extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrSave;
  const SaveButton(
    this.constraints, {
    Key? key,
    this.ovrSave,
  }) : super(key: key);
  @override
  _SaveButton createState() => _SaveButton();
}

class _SaveButton extends State<SaveButton> {
  _SaveButton();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: SaveButtonCustom(
            child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: Stack(children: [
              Positioned(
                left: 0,
                width: 311.0,
                top: 0,
                height: 35.0,
                child: Container(
                  height: 35.0,
                  width: 311.0,
                  decoration: BoxDecoration(
                    color: Color(0xff7ac231),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
              Positioned(
                left: 143.0,
                width: 27.0,
                top: 11.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 27.0,
                    child: AutoSizeText(
                      widget.ovrSave ?? 'Save',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
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
