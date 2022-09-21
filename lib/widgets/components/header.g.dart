// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/options_custom.dart';

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
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
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
              Positioned(
                left: widget.constraints.maxWidth * 0.984,
                width: widget.constraints.maxWidth * 0.013,
                top: widget.constraints.maxHeight * 0.25,
                height: widget.constraints.maxHeight * 0.571,
                child: OptionsCustom(
                    child: Image.asset(
                  'assets/images/optionscustom.png',
                  package: 'genius_wallet',
                  height: widget.constraints.maxHeight * 0.5714285714285714,
                  width: widget.constraints.maxWidth * 0.01282051282051282,
                  fit: BoxFit.fill,
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
