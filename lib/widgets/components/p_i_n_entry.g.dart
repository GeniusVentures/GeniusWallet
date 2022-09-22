// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/p_i_n_mask_custom.dart';

class PINEntry extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrPINtext;
  final Widget? ovrEllipse22;
  final Widget? ovrEllipse21;
  final Widget? ovrEllipse20;
  final Widget? ovrEllipse19;
  final Widget? ovrEllipse18;
  final Widget? ovrEllipse17;
  const PINEntry(
    this.constraints, {
    Key? key,
    this.ovrPINtext,
    this.ovrEllipse22,
    this.ovrEllipse21,
    this.ovrEllipse20,
    this.ovrEllipse19,
    this.ovrEllipse18,
    this.ovrEllipse17,
  }) : super(key: key);
  @override
  _PINEntry createState() => _PINEntry();
}

class _PINEntry extends State<PINEntry> {
  _PINEntry();

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
                left: 71.0,
                right: 64.0,
                top: 0,
                height: widget.constraints.maxHeight * 0.226,
                child: Center(
                    child: Container(
                        height: 19.0,
                        width:
                            widget.constraints.maxWidth * 0.36619718309859156,
                        child: AutoSizeText(
                          widget.ovrPINtext ?? 'Create PIN',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.0,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ))),
              ),
              Positioned(
                left: 0,
                width: widget.constraints.maxWidth * 1.0,
                top: widget.constraints.maxHeight * 0.786,
                height: widget.constraints.maxHeight * 0.214,
                child: Center(
                    child: Container(
                        height: 18.0,
                        width: 213.0,
                        child: PINMaskCustom(
                            child: Container(
                                decoration: BoxDecoration(),
                                child: Stack(children: [
                                  Positioned(
                                    left: 0,
                                    width: 18.0,
                                    top: 0,
                                    height: 18.0,
                                    child: widget.ovrEllipse17 ??
                                        Image.asset(
                                          'assets/images/ellipse17.png',
                                          package: 'genius_wallet',
                                          height: 18.0,
                                          width: 18.0,
                                          fit: BoxFit.none,
                                        ),
                                  ),
                                  Positioned(
                                    left: 39.0,
                                    width: 18.0,
                                    top: 0,
                                    height: 18.0,
                                    child: widget.ovrEllipse18 ??
                                        Image.asset(
                                          'assets/images/ellipse18.png',
                                          package: 'genius_wallet',
                                          height: 18.0,
                                          width: 18.0,
                                          fit: BoxFit.none,
                                        ),
                                  ),
                                  Positioned(
                                    left: 78.0,
                                    width: 18.0,
                                    top: 0,
                                    height: 18.0,
                                    child: widget.ovrEllipse19 ??
                                        Image.asset(
                                          'assets/images/ellipse19.png',
                                          package: 'genius_wallet',
                                          height: 18.0,
                                          width: 18.0,
                                          fit: BoxFit.none,
                                        ),
                                  ),
                                  Positioned(
                                    left: 117.0,
                                    width: 18.0,
                                    top: 0,
                                    height: 18.0,
                                    child: widget.ovrEllipse20 ??
                                        Image.asset(
                                          'assets/images/ellipse20.png',
                                          package: 'genius_wallet',
                                          height: 18.0,
                                          width: 18.0,
                                          fit: BoxFit.none,
                                        ),
                                  ),
                                  Positioned(
                                    left: 156.0,
                                    width: 18.0,
                                    top: 0,
                                    height: 18.0,
                                    child: widget.ovrEllipse21 ??
                                        Image.asset(
                                          'assets/images/ellipse21.png',
                                          package: 'genius_wallet',
                                          height: 18.0,
                                          width: 18.0,
                                          fit: BoxFit.none,
                                        ),
                                  ),
                                  Positioned(
                                    left: 195.0,
                                    width: 18.0,
                                    top: 0,
                                    height: 18.0,
                                    child: widget.ovrEllipse22 ??
                                        Image.asset(
                                          'assets/images/ellipse22.png',
                                          package: 'genius_wallet',
                                          height: 18.0,
                                          width: 18.0,
                                          fit: BoxFit.none,
                                        ),
                                  ),
                                ]))))),
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
