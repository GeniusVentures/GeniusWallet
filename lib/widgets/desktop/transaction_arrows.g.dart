// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';

class TransactionArrows extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrArrowRight;
  final Widget? ovrArrowLeft;
  const TransactionArrows(
    this.constraints, {
    Key? key,
    this.ovrArrowRight,
    this.ovrArrowLeft,
  }) : super(key: key);
  @override
  _TransactionArrows createState() => _TransactionArrows();
}

class _TransactionArrows extends State<TransactionArrows> {
  _TransactionArrows();

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
                height: widget.constraints.maxHeight * 0.35,
                child: widget.ovrArrowRight ??
                    Image.asset(
                      'assets/images/arrowright.png',
                      package: 'genius_wallet',
                      height: widget.constraints.maxHeight * 0.3499290194617561,
                      width: widget.constraints.maxWidth * 1.0,
                      fit: BoxFit.fill,
                    ),
              ),
              Positioned(
                left: 0,
                width: widget.constraints.maxWidth * 1.0,
                top: widget.constraints.maxHeight * 0.65,
                height: widget.constraints.maxHeight * 0.35,
                child: widget.ovrArrowLeft ??
                    Image.asset(
                      'assets/images/arrowleft.png',
                      package: 'genius_wallet',
                      height: widget.constraints.maxHeight * 0.3499290194617561,
                      width: widget.constraints.maxWidth * 1.0,
                      fit: BoxFit.fill,
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
