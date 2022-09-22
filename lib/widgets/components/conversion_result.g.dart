// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ConversionResult extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrResult;
  final String? ovrAmountentered;
  const ConversionResult(
    this.constraints, {
    Key? key,
    this.ovrResult,
    this.ovrAmountentered,
  }) : super(key: key);
  @override
  _ConversionResult createState() => _ConversionResult();
}

class _ConversionResult extends State<ConversionResult> {
  _ConversionResult();

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
                right: 4.0,
                top: 0,
                bottom: 0,
                child: Container(
                  height: widget.constraints.maxHeight * 1.0,
                  width: widget.constraints.maxWidth * 0.9869281045751634,
                  decoration: BoxDecoration(
                    color: Color(0xff2a2b31),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.248,
                width: widget.constraints.maxWidth * 0.52,
                top: widget.constraints.maxHeight * 0.568,
                height: widget.constraints.maxHeight * 0.061,
                child: Center(
                    child: Container(
                        height: 8.0,
                        width: 159.0,
                        child: AutoSizeText(
                          widget.ovrResult ?? 'BTC = 3748.76 USD',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 18.0,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.26999998092651367,
                            color: Color(0xff6b6b71),
                          ),
                          textAlign: TextAlign.center,
                        ))),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.075,
                width: widget.constraints.maxWidth * 0.846,
                top: widget.constraints.maxHeight * 0.189,
                height: widget.constraints.maxHeight * 0.197,
                child: Center(
                    child: Container(
                        height: 26.0,
                        width: 259.0,
                        child: AutoSizeText(
                          widget.ovrAmountentered ?? '0.3333333333',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 34.0,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.5100001096725464,
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
