// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';

class StatusPending extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrStatus;
  const StatusPending(
    this.constraints, {
    Key? key,
    this.ovrStatus,
  }) : super(key: key);
  @override
  _StatusPending createState() => _StatusPending();
}

class _StatusPending extends State<StatusPending> {
  _StatusPending();

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
                    color: Color(0xff4c4d55),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
              Positioned(
                left: 91.0,
                width: 21.0,
                top: 10.0,
                height: 18.0,
                child: SvgPicture.asset(
                  'assets/images/pendingstatuslogo.svg',
                  package: 'genius_wallet',
                  height: 18.0,
                  width: 21.0,
                  fit: BoxFit.none,
                ),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.083,
                width: widget.constraints.maxWidth * 0.545,
                top: widget.constraints.maxHeight * 0.286,
                height: widget.constraints.maxHeight * 0.4,
                child: Center(
                    child: Container(
                        height: 14.0,
                        width: widget.constraints.maxWidth * 0.5454545454545454,
                        child: AutoSizeText(
                          widget.ovrStatus ?? 'Pending',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.30000001192092896,
                            color: Color(0xff78797e),
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
