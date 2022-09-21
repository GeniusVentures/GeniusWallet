// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/type_create_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class TypeCreate extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrCreateaWallet;
  const TypeCreate(
    this.constraints, {
    Key? key,
    this.ovrCreateaWallet,
  }) : super(key: key);
  @override
  _TypeCreate createState() => _TypeCreate();
}

class _TypeCreate extends State<TypeCreate> {
  _TypeCreate();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Color(0xff0068ef),
        ),
        child: TypeCreateCustom(
            child: Stack(children: [
          Positioned(
            left: widget.constraints.maxWidth * 0.292,
            width: widget.constraints.maxWidth * 0.416,
            top: 16.0,
            height: 13.0,
            child: Center(
                child: Container(
                    height: 13.0,
                    width: 131.0,
                    child: AutoSizeText(
                      widget.ovrCreateaWallet ?? 'Create a Wallet',
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
