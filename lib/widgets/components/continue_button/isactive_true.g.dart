// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/isactive_true_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class IsactiveTrue extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrContinue;
  const IsactiveTrue(
    this.constraints, {
    Key? key,
    this.ovrContinue,
  }) : super(key: key);
  @override
  _IsactiveTrue createState() => _IsactiveTrue();
}

class _IsactiveTrue extends State<IsactiveTrue> {
  _IsactiveTrue();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: IsactiveTrueCustom(
            child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: Container(
              color: Colors.purple,
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
                      gradient: LinearGradient(
                        begin: Alignment(
                            -0.8444444484172715, -2.945831951706168e-7),
                        end: Alignment(0.9047618681449168, 0.999998242777302),
                        colors: <Color>[
                          Color(0xff00a9fe),
                          Color(0xff00f4a8),
                        ],
                        stops: [
                          0.0,
                          1.0,
                        ],
                        tileMode: TileMode.clamp,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 115.0,
                  right: 112.0,
                  top: 16.0,
                  bottom: 17.0,
                  child: Container(
                      height: widget.constraints.maxHeight * 0.2826086956521739,
                      width: widget.constraints.maxWidth * 0.27936507936507937,
                      child: AutoSizeText(
                        widget.ovrContinue ?? 'Continue',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 11.0,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.13750000298023224,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      )),
                ),
              ]),
            ),
          ),
        ])));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
