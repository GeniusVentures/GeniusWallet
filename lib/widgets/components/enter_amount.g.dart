// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/enter_amount_logic.dart';
import 'package:genius_wallet/widgets/components/enter_amount_widget.g.dart';

class EnterAmount extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrENTERAMOUNT;
  final Widget? ovrCheckmarksuffixicon;
  final String? ovramounthinttext;
  const EnterAmount(
    this.constraints, {
    Key? key,
    this.ovrENTERAMOUNT,
    this.ovrCheckmarksuffixicon,
    this.ovramounthinttext,
  }) : super(key: key);
  @override
  _EnterAmount createState() => _EnterAmount();
}

class _EnterAmount extends State<EnterAmount> {
  _EnterAmount();

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
                width: 126.0,
                top: 0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 126.0,
                    child: AutoSizeText(
                      widget.ovrENTERAMOUNT ?? 'ENTER AMOUNT',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.25714290142059326,
                        color: Color(0xff3a3c43),
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 0,
                width: 315.0,
                top: 43.0,
                height: 61.0,
                child: EnterAmountWidget(),
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
