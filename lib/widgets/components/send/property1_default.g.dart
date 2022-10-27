// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Property1Default extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrSend;
  const Property1Default(
    this.constraints, {
    Key? key,
    this.ovrSend,
  }) : super(key: key);
  @override
  _Property1Default createState() => _Property1Default();
}

class _Property1Default extends State<Property1Default> {
  _Property1Default();

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
                width: 90.0,
                top: 0,
                height: 23.0,
                child: Container(
                  height: 23.0,
                  width: 90.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(14.0)),
                    border: Border.all(
                      color: Color(0xff3f4048),
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.289,
                width: widget.constraints.maxWidth * 0.422,
                top: widget.constraints.maxHeight * 0.217,
                height: widget.constraints.maxHeight * 0.609,
                child: Center(
                    child: Container(
                        height: 14.0,
                        width: 38.0,
                        child: AutoSizeText(
                          widget.ovrSend ?? 'Send ',
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
            ]),
          ),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
