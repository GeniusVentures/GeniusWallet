// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TransactionCard extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrTimestamp;
  final String? ovrTransactionID;
  final String? ovrTransactionQuantity;
  const TransactionCard(
    this.constraints, {
    Key? key,
    this.ovrTimestamp,
    this.ovrTransactionID,
    this.ovrTransactionQuantity,
  }) : super(key: key);
  @override
  _TransactionCard createState() => _TransactionCard();
}

class _TransactionCard extends State<TransactionCard> {
  _TransactionCard();

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
                  ),
                ),
              ),
              Positioned(
                left: 9.0,
                width: 88.0,
                top: 15.0,
                height: 12.0,
                child: Container(
                    height: 12.0,
                    width: 88.0,
                    child: AutoSizeText(
                      widget.ovrTimestamp ?? '16:23, 12 dec 2018',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 10.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.048,
                width: widget.constraints.maxWidth * 0.889,
                top: widget.constraints.maxHeight * 0.639,
                height: widget.constraints.maxHeight * 0.194,
                child: Container(
                    height: widget.constraints.maxHeight * 0.19444649174528303,
                    width: widget.constraints.maxWidth * 0.8892988929889298,
                    child: AutoSizeText(
                      widget.ovrTransactionID ??
                          '1PRj85hu9RXPZTzxtko9stfs6nRo1vyrQB',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.30000001192092896,
                        color: Color(0xff42434b),
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                right: 10.0,
                width: 81.0,
                top: 13.0,
                height: 14.0,
                child: Container(
                    decoration: BoxDecoration(),
                    child: Stack(children: [
                      Positioned(
                        right: 0,
                        width: 64.0,
                        top: 0,
                        height: 14.0,
                        child: Container(
                            height: 14.0,
                            width: 64.0,
                            child: AutoSizeText(
                              widget.ovrTransactionQuantity ?? '0.009 BTC',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.0,
                                color: Color(0xfffefefe),
                              ),
                              textAlign: TextAlign.right,
                            )),
                      ),
                      Positioned(
                        right: 66.0,
                        width: 12.0,
                        top: 3.0,
                        height: 8.0,
                        child: SvgPicture.asset(
                          'assets/images/transactiontype.svg',
                          package: 'genius_wallet',
                          height: 8.0,
                          width: 12.0,
                          fit: BoxFit.none,
                        ),
                      ),
                    ])),
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
