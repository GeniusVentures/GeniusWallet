// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EnterAmountDesktop extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrENTERAMOUNT;
  final String? ovr03333333333333;
  final Widget? ovrMask;
  const EnterAmountDesktop(
    this.constraints, {
    Key? key,
    this.ovrENTERAMOUNT,
    this.ovr03333333333333,
    this.ovrMask,
  }) : super(key: key);
  @override
  _EnterAmountDesktop createState() => _EnterAmountDesktop();
}

class _EnterAmountDesktop extends State<EnterAmountDesktop> {
  _EnterAmountDesktop();

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
                width: 94.0,
                top: 0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 94.0,
                    child: AutoSizeText(
                      widget.ovrENTERAMOUNT ?? 'ENTER AMOUNT',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.25714290142059326,
                        color: Color(0xff3a3c43),
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 0,
                width: 568.5,
                top: 27.8,
                height: 91.4,
                child: Container(
                    decoration: BoxDecoration(),
                    child: Stack(children: [
                      Positioned(
                        left: 0,
                        width: 568.5,
                        top: 0,
                        height: 91.4,
                        child: Container(
                          height: 91.39990234375,
                          width: 568.5,
                          decoration: BoxDecoration(
                            color: Color(0xff2a2b31),
                            borderRadius:
                                BorderRadius.all(Radius.circular(2.0)),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 9.0,
                        width: 329.0,
                        top: 22.44,
                        height: 47.0,
                        child: Container(
                            height: 47.0,
                            width: 329.0,
                            child: AutoSizeText(
                              widget.ovr03333333333333 ?? '0.3333333333333',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 40.0,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 0.6000000238418579,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            )),
                      ),
                    ])),
              ),
              Positioned(
                left: 499.074,
                width: 38.372,
                top: 58.893,
                height: 29.215,
                child: widget.ovrMask ??
                    SvgPicture.asset(
                      'assets/images/mask.svg',
                      package: 'genius_wallet',
                      height: 29.21484375,
                      width: 38.37158203125,
                      fit: BoxFit.none,
                    ),
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
