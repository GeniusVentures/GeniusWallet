// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/detailed_transaction_options_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/detailed_transaction_status_custom.dart';

class DetailedTransaction extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrTimestamp;
  final Widget? ovrTransactionArrow;
  final String? ovrTransactionID;
  final String? ovrTransactionValue;
  final Widget? ovrMask2;
  final Widget? ovrMask3;
  final String? ovrCompleted;
  final Widget? ovrCoinIcon;
  const DetailedTransaction(
    this.constraints, {
    Key? key,
    this.ovrTimestamp,
    this.ovrTransactionArrow,
    this.ovrTransactionID,
    this.ovrTransactionValue,
    this.ovrMask2,
    this.ovrMask3,
    this.ovrCompleted,
    this.ovrCoinIcon,
  }) : super(key: key);
  @override
  _DetailedTransaction createState() => _DetailedTransaction();
}

class _DetailedTransaction extends State<DetailedTransaction> {
  _DetailedTransaction();

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
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  height: widget.constraints.maxHeight * 1.0,
                  width: widget.constraints.maxWidth * 1.0,
                  decoration: BoxDecoration(
                    color: Color(0xff2a2b31),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
              Positioned(
                left: 25.0,
                width: 4.0,
                top: 18.0,
                height: 16.0,
                child: DetailedTransactionOptionsCustom(
                    child: SvgPicture.asset(
                  'assets/images/detailedtransactionoptionscustom.svg',
                  package: 'genius_wallet',
                  height: 16.0,
                  width: 4.0,
                  fit: BoxFit.none,
                )),
              ),
              Positioned(
                left: 39.0,
                width: 124.0,
                top: 17.0,
                height: 16.0,
                child: Container(
                    height: 16.0,
                    width: 124.0,
                    child: AutoSizeText(
                      widget.ovrTimestamp ?? '16:23, 12 dec 2018',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3500000238418579,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.right,
                    )),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.079,
                width: widget.constraints.maxWidth * 0.051,
                top: widget.constraints.maxHeight * 0.46,
                height: widget.constraints.maxHeight * 0.056,
                child: Center(
                    child: Container(
                        height: 10.666664123535156,
                        width: 16.0,
                        child: widget.ovrTransactionArrow ??
                            SvgPicture.asset(
                              'assets/images/transactionarrow.svg',
                              package: 'genius_wallet',
                              height: 10.666664123535156,
                              width: 16.0,
                              fit: BoxFit.scaleDown,
                            ))),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.149,
                width: widget.constraints.maxWidth * 0.829,
                top: widget.constraints.maxHeight * 0.444,
                height: widget.constraints.maxHeight * 0.159,
                child: Center(
                    child: Container(
                        height: 30.0,
                        width: 262.0,
                        child: AutoSizeText(
                          widget.ovrTransactionID ??
                              '1Cs4wu6pu5qCZ35bSLNVzGyEx5N6uzbg9t',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 13.0,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.32499998807907104,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.left,
                        ))),
              ),
              Positioned(
                left: 9.0,
                width: 141.0,
                bottom: 29.0,
                height: 23.0,
                child: Container(
                    height: 23.0,
                    width: 141.0,
                    child: AutoSizeText(
                      widget.ovrTransactionValue ?? '0.0094 LTC',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 20.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.right,
                    )),
              ),
              Positioned(
                right: 20.0,
                width: 121.0,
                bottom: 24.0,
                height: 35.0,
                child: DetailedTransactionStatusCustom(
                    child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(),
                        child: Stack(children: [
                          Positioned(
                            left: 0,
                            width: 121.0,
                            top: 0,
                            height: 35.0,
                            child: Container(
                              height: 35.0,
                              width: 121.0,
                              decoration: BoxDecoration(
                                color: Color(0xff7ac131),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2.0)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 7.0,
                            width: 77.0,
                            top: 10.0,
                            height: 14.0,
                            child: Container(
                                height: 14.0,
                                width: 77.0,
                                child: AutoSizeText(
                                  widget.ovrCompleted ?? 'Completed',
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
                          Positioned(
                            left: 91.0,
                            width: 17.6,
                            top: 10.0,
                            height: 13.4,
                            child: widget.ovrMask3 ??
                                SvgPicture.asset(
                                  'assets/images/mask3.svg',
                                  package: 'genius_wallet',
                                  height: 13.399993896484375,
                                  width: 17.60009765625,
                                  fit: BoxFit.none,
                                ),
                          ),
                          Positioned(
                            left: 91.0,
                            width: 17.6,
                            top: 10.0,
                            height: 13.4,
                            child: widget.ovrMask2 ??
                                SvgPicture.asset(
                                  'assets/images/mask2.svg',
                                  package: 'genius_wallet',
                                  height: 13.399993896484375,
                                  width: 17.60009765625,
                                  fit: BoxFit.none,
                                ),
                          ),
                        ]))),
              ),
              Positioned(
                right: 20.906,
                width: 35.0,
                top: 16.234,
                height: 35.0,
                child: widget.ovrCoinIcon ??
                    SvgPicture.asset(
                      'assets/images/coinicon.svg',
                      package: 'genius_wallet',
                      height: 35.0,
                      width: 35.0,
                      fit: BoxFit.none,
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
