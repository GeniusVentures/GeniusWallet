// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/genius_close_button_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class GeniusCloseButton extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrCloseText;
  const GeniusCloseButton(
    this.constraints, {
    Key? key,
    this.ovrCloseText,
  }) : super(key: key);
  @override
  _GeniusCloseButton createState() => _GeniusCloseButton();
}

class _GeniusCloseButton extends State<GeniusCloseButton> {
  _GeniusCloseButton();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: GeniusCloseButtonCustom(
            child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: Stack(children: [
              Positioned(
                left: 0,
                width: 79.0,
                top: 0,
                height: 35.0,
                child: Container(
                  height: 35.0,
                  width: 79.0,
                  decoration: BoxDecoration(
                    color: Color(0xff2a2b31),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
              Positioned(
                left: 13.0,
                right: 13.0,
                top: 11.0,
                bottom: 10.0,
                child: Container(
                    height: widget.constraints.maxHeight * 0.4,
                    width: widget.constraints.maxWidth * 0.6708860759493671,
                    child: AutoSizeText(
                      widget.ovrCloseText ?? 'Close',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
            ]),
          ),
        ])));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
