import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
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
            width: widget.constraints.maxWidth,
            top: 0,
            height: widget.constraints.maxHeight,
            child: Stack(children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                    child: AutoSizeText(
                  widget.ovrENTERAMOUNT ?? 'Enter Amount',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                    color: GeniusWalletColors.gray500,
                  ),
                  textAlign: TextAlign.left,
                )),
              ),
              Positioned(
                left: 0,
                width: widget.constraints.maxWidth,
                top: 30.0,
                height: 61.0,
                child: EnterAmountWidget(
                  logic: EnterAmountLogic(context),
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
