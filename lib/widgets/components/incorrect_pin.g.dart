// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class IncorrectPin extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrIncorrectPinLabel;
  const IncorrectPin(
    this.constraints, {
    Key? key,
    this.ovrIncorrectPinLabel,
  }) : super(key: key);
  @override
  _IncorrectPin createState() => _IncorrectPin();
}

class _IncorrectPin extends State<IncorrectPin> {
  _IncorrectPin();

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
            child: Stack(children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  height: widget.constraints.maxHeight * 1.0,
                  width: widget.constraints.maxWidth * 1.0,
                  decoration: BoxDecoration(
                    color: Color(0xfff40000),
                    borderRadius: BorderRadius.all(Radius.circular(100.0)),
                  ),
                ),
              ),
              Positioned(
                left: 35.0,
                right: 34.0,
                top: 6.0,
                bottom: 9.0,
                child: Container(
                    height: widget.constraints.maxHeight * 0.5588235294117647,
                    width: widget.constraints.maxWidth * 0.56875,
                    child: AutoSizeText(
                      widget.ovrIncorrectPinLabel ?? 'Incorrect Pin',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
            ]),
          ),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
