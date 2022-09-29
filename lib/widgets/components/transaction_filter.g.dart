// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/transaction_filter_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class TransactionFilter extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrALL;
  final String? ovrSEND;
  final String? ovrRECENT;
  const TransactionFilter(
    this.constraints, {
    Key? key,
    this.ovrALL,
    this.ovrSEND,
    this.ovrRECENT,
  }) : super(key: key);
  @override
  _TransactionFilter createState() => _TransactionFilter();
}

class _TransactionFilter extends State<TransactionFilter> {
  _TransactionFilter();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: TransactionFilterCustom(
            child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.047,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: Stack(children: [
              Positioned(
                left: 0,
                width: 40.0,
                top: 0,
                height: 13.0,
                child: Container(
                    height: 13.0,
                    width: 40.0,
                    child: AutoSizeText(
                      widget.ovrALL ?? 'ALL',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
              Positioned(
                left: 38.0,
                right: 65.0,
                top: 0,
                height: 13.0,
                child: Container(
                    height: 13.0,
                    width: widget.constraints.maxWidth * 0.36,
                    child: AutoSizeText(
                      widget.ovrSEND ?? 'SEND',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4124999940395355,
                        color: Color(0xff606166),
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
              Positioned(
                right: 0,
                width: 74.0,
                top: 0,
                height: 13.0,
                child: Container(
                    height: 13.0,
                    width: 74.0,
                    child: AutoSizeText(
                      widget.ovrRECENT ?? 'RECENT',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4124999940395355,
                        color: Color(0xff606166),
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
