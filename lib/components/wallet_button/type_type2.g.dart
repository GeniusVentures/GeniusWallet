// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/components/custom/type_type2_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class TypeType2 extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrIalreadyhaveawallet;
  const TypeType2(
    this.constraints, {
    Key? key,
    this.ovrIalreadyhaveawallet,
  }) : super(key: key);
  @override
  _TypeType2 createState() => _TypeType2();
}

class _TypeType2 extends State<TypeType2> {
  _TypeType2();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xff0068ef),
            width: 1.0,
          ),
        ),
        child: TypeType2Custom(
            child: Stack(children: [
          Positioned(
            left: widget.constraints.maxWidth * 0.324,
            width: widget.constraints.maxWidth * 0.352,
            top: 17.0,
            height: 13.0,
            child: Center(
                child: Container(
                    height: 13.0,
                    width: 111.0,
                    child: AutoSizeText(
                      widget.ovrIalreadyhaveawallet ??
                          'I already have a wallet',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.13750000298023224,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ))),
          ),
        ])));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
