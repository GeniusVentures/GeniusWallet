// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Header extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrHeaderName;
  const Header(
    this.constraints, {
    Key? key,
    this.ovrHeaderName,
  }) : super(key: key);
  @override
  _Header createState() => _Header();
}

class _Header extends State<Header> {
  _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: Stack(children: [
          Positioned(
            left: 0,
            width: 213.0,
            top: 0,
            height: 28.0,
            child: Container(
                height: 28.0,
                width: 213.0,
                child: AutoSizeText(
                  widget.ovrHeaderName ?? 'Header Name',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 24.0,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.30000001192092896,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.left,
                )),
          ),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
