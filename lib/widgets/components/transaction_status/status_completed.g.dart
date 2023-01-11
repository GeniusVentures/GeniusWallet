// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';

class StatusCompleted extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrStatus;
  const StatusCompleted(
    this.constraints, {
    Key? key,
    this.ovrStatus,
  }) : super(key: key);
  @override
  _StatusCompleted createState() => _StatusCompleted();
}

class _StatusCompleted extends State<StatusCompleted> {
  _StatusCompleted();

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
                    color: Color(0xff7ac131),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
              Positioned(
                left: 91.0,
                width: 17.6,
                top: 10.0,
                height: 13.4,
                child: SvgPicture.asset(
                  'assets/images/completedstatuslogo.svg',
                  package: 'genius_wallet',
                  height: 13.4000244140625,
                  width: 17.599609375,
                  fit: BoxFit.none,
                ),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.05,
                width: widget.constraints.maxWidth * 0.653,
                top: widget.constraints.maxHeight * 0.286,
                height: widget.constraints.maxHeight * 0.4,
                child: Center(
                    child: Container(
                        height: 14.0,
                        width: widget.constraints.maxWidth * 0.6528925619834711,
                        child: AutoSizeText(
                          widget.ovrStatus ?? 'Completed',
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
