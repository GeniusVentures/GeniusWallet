// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Cancelled extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrStatus;
  const Cancelled(
    this.constraints, {
    Key? key,
    this.ovrStatus,
  }) : super(key: key);
  @override
  _Cancelled createState() => _Cancelled();
}

class _Cancelled extends State<Cancelled> {
  _Cancelled();

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
                width: widget.constraints.maxWidth * 1.0,
                top: 0,
                height: widget.constraints.maxHeight * 1.0,
                child: Container(
                  height: widget.constraints.maxHeight * 1.0,
                  width: widget.constraints.maxWidth * 1.0,
                  decoration: BoxDecoration(
                    color: Color(0xff920000),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
              Positioned(
                left: 91.0,
                width: 10.667,
                top: 10.0,
                height: 10.667,
                child: SvgPicture.asset(
                  'assets/images/cancelledstatuslogo.svg',
                  package: 'genius_wallet',
                  height: 10.666671752929688,
                  width: 10.6669921875,
                  fit: BoxFit.none,
                ),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.116,
                width: widget.constraints.maxWidth * 0.562,
                top: widget.constraints.maxHeight * 0.286,
                height: widget.constraints.maxHeight * 0.4,
                child: Center(
                    child: Container(
                        height: 14.0,
                        width: widget.constraints.maxWidth * 0.5619834710743802,
                        child: AutoSizeText(
                          widget.ovrStatus ?? 'Cancelled',
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
