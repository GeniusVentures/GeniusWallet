// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/desktop/custom/general_card_custom.dart';

class GeneralCard extends StatefulWidget {
  final BoxConstraints constraints;

  const GeneralCard(
    this.constraints, {
    Key? key,
  }) : super(key: key);
  @override
  _GeneralCard createState() => _GeneralCard();
}

class _GeneralCard extends State<GeneralCard> {
  _GeneralCard();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: GeneralCardCustom(
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
                color: Color(0xff1e2025),
                borderRadius:
                    BorderRadius.all(Radius.circular(2.3987138271331787)),
              ),
            ),
          ),
        ])));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
