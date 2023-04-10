// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CalculatorOutPut extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovr03333333333333BTC;
  const CalculatorOutPut(
    this.constraints, {
    Key? key,
    this.ovr03333333333333BTC,
  }) : super(key: key);
  @override
  _CalculatorOutPut createState() => _CalculatorOutPut();
}

class _CalculatorOutPut extends State<CalculatorOutPut> {
  _CalculatorOutPut();

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
                width: 568.5,
                top: 0,
                height: 68.0,
                child: Container(
                  height: 68.0,
                  width: 568.5,
                  decoration: BoxDecoration(
                    color: Color(0xff2a2b31),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
              Positioned(
                left: 24.0,
                width: 520.0,
                top: 18.0,
                height: 35.0,
                child: Container(
                    height: 35.0,
                    width: 520.0,
                    child: AutoSizeText(
                      widget.ovr03333333333333BTC ??
                          '0.3333333333333 BTC = 3748.76 USD',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 30.0,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.45000001788139343,
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
