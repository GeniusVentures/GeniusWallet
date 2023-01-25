// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class TypeWithwallet extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrYourbitcoinadress;
  final String? ovrYourbitcoinadress2;
  final String? ovrYourbitcoinadress3;
  final String? ovrYourbitcoinadress4;
  const TypeWithwallet(
    this.constraints, {
    Key? key,
    this.ovrYourbitcoinadress,
    this.ovrYourbitcoinadress2,
    this.ovrYourbitcoinadress3,
    this.ovrYourbitcoinadress4,
  }) : super(key: key);
  @override
  _TypeWithwallet createState() => _TypeWithwallet();
}

class _TypeWithwallet extends State<TypeWithwallet> {
  _TypeWithwallet();

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
                    color: Color(0xff2a2b31),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.057,
                width: widget.constraints.maxWidth * 0.312,
                top: widget.constraints.maxHeight * 0.193,
                height: widget.constraints.maxHeight * 0.169,
                child: Container(
                    height: widget.constraints.maxHeight * 0.1686746987951807,
                    width: widget.constraints.maxWidth * 0.31230306327962576,
                    child: AutoSizeText(
                      widget.ovrYourbitcoinadress ?? 'Available Balance',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.703,
                width: widget.constraints.maxWidth * 0.249,
                top: widget.constraints.maxHeight * 0.193,
                height: widget.constraints.maxHeight * 0.169,
                child: Container(
                    height: widget.constraints.maxHeight * 0.1686746987951807,
                    width: widget.constraints.maxWidth * 0.24921123798076922,
                    child: AutoSizeText(
                      widget.ovrYourbitcoinadress2 ?? '0.221764 BTC',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.right,
                    )),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.057,
                width: widget.constraints.maxWidth * 0.142,
                top: widget.constraints.maxHeight * 0.651,
                height: widget.constraints.maxHeight * 0.169,
                child: Container(
                    height: widget.constraints.maxHeight * 0.1686746987951807,
                    width: widget.constraints.maxWidth * 0.14195584556912683,
                    child: AutoSizeText(
                      widget.ovrYourbitcoinadress3 ?? 'Gas Fee',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.703,
                width: widget.constraints.maxWidth * 0.249,
                top: widget.constraints.maxHeight * 0.651,
                height: widget.constraints.maxHeight * 0.169,
                child: Container(
                    height: widget.constraints.maxHeight * 0.1686746987951807,
                    width: widget.constraints.maxWidth * 0.24921123798076922,
                    child: AutoSizeText(
                      widget.ovrYourbitcoinadress4 ?? '0.000014 BTC',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.right,
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
