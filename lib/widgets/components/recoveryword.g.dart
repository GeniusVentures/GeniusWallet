// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Recoveryword extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrWord;
  const Recoveryword(
    this.constraints, {
    Key? key,
    this.ovrWord,
  }) : super(key: key);
  @override
  _Recoveryword createState() => _Recoveryword();
}

class _Recoveryword extends State<Recoveryword> {
  _Recoveryword();

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
            child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(),
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
                        borderRadius: BorderRadius.all(Radius.circular(3.0)),
                        border: Border.all(
                          color: Color(0xff00efae),
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: widget.constraints.maxWidth * 0.118,
                    width: widget.constraints.maxWidth * 0.784,
                    top: widget.constraints.maxHeight * 0.286,
                    height: widget.constraints.maxHeight * 0.464,
                    child: Center(
                        child: Container(
                            height: 13.0,
                            width: widget.constraints.maxWidth *
                                0.7843137174039274,
                            child: AutoSizeText(
                              widget.ovrWord ?? '1 limb',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 16.0,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 0.0,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ))),
                  ),
                ])),
          ),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
