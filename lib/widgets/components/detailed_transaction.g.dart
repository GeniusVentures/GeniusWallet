// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/transaction_options_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:genius_wallet/widgets/components/custom/transaction_type_icon_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/transaction_status_custom.dart';

class DetailedTransaction extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrTimestamp;
  final String? ovrTransactionID;
  final String? ovrTransactionValue;
  final Widget? ovrMask3;
  final Widget? ovrMask4;
  final String? ovrCompleted;
  final Widget? ovrShape;
  const DetailedTransaction(
    this.constraints, {
    Key? key,
    this.ovrTimestamp,
    this.ovrTransactionID,
    this.ovrTransactionValue,
    this.ovrMask3,
    this.ovrMask4,
    this.ovrCompleted,
    this.ovrShape,
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
                left: widget.constraints.maxWidth * 0.016,
                width: widget.constraints.maxWidth * 0.984,
                top: 0,
                height: widget.constraints.maxHeight * 1.0,
                child: Container(
                  height: widget.constraints.maxHeight * 1.0,
                  width: widget.constraints.maxWidth * 0.9841772151898734,
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
                child: TransactionOptionsCustom(
                    child: SvgPicture.asset(
                  'assets/images/transactionoptionscustom.svg',
                  package: 'genius_wallet',
                  height: 16.0,
                  width: 4.0,
                  fit: BoxFit.none,
                )),
              ),
              Positioned(
                left: 25.0,
                width: 16.0,
                top: 87.0,
                height: 10.667,
                child: TransactionTypeIconCustom(
                    child: SvgPicture.asset(
                  'assets/images/transactiontypeiconcustom.svg',
                  package: 'genius_wallet',
                  height: 10.66650390625,
                  width: 16.0,
                  fit: BoxFit.none,
                )),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.123,
                width: widget.constraints.maxWidth * 0.392,
                top: widget.constraints.maxHeight * 0.09,
                height: widget.constraints.maxHeight * 0.085,
                child: Center(
                    child: Container(
                        height: 16.0,
                        width: widget.constraints.maxWidth * 0.3924050632911392,
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
                        width: widget.constraints.maxWidth * 0.8291139240506329,
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
                left: widget.constraints.maxWidth * 0.028,
                width: widget.constraints.maxWidth * 0.389,
                top: widget.constraints.maxHeight * 0.725,
                height: widget.constraints.maxHeight * 0.122,
                child: Center(
                    child: Container(
                        height: 23.0,
                        width:
                            widget.constraints.maxWidth * 0.38924050632911394,
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
                        ))),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.554,
                width: widget.constraints.maxWidth * 0.383,
                top: widget.constraints.maxHeight * 0.688,
                height: widget.constraints.maxHeight * 0.185,
                child: TransactionStatusCustom(
                    child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(),
                        child: Stack(children: [
                          Positioned(
                            left: 0,
                            width: widget.constraints.maxWidth * 0.383,
                            top: 0,
                            height: widget.constraints.maxHeight * 0.185,
                            child: Container(
                              height: widget.constraints.maxHeight *
                                  0.18518518518518517,
                              width: widget.constraints.maxWidth *
                                  0.3829113924050633,
                              decoration: BoxDecoration(
                                color: Color(0xff7ac131),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2.0)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: widget.constraints.maxWidth * 0.022,
                            width: widget.constraints.maxWidth * 0.244,
                            top: widget.constraints.maxHeight * 0.053,
                            height: widget.constraints.maxHeight * 0.074,
                            child: Center(
                                child: Container(
                                    height: 14.0,
                                    width: widget.constraints.maxWidth *
                                        0.24367088607594936,
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
                                    ))),
                          ),
                          Positioned(
                            left: widget.constraints.maxWidth * 0.288,
                            width: widget.constraints.maxWidth * 0.056,
                            top: widget.constraints.maxHeight * 0.053,
                            height: widget.constraints.maxHeight * 0.071,
                            child: widget.ovrMask4 ??
                                SvgPicture.asset(
                                  'assets/images/mask4.svg',
                                  package: 'genius_wallet',
                                  height: widget.constraints.maxHeight *
                                      0.07089895419973545,
                                  width: widget.constraints.maxWidth *
                                      0.055696511570411396,
                                  fit: BoxFit.fill,
                                ),
                          ),
                          Positioned(
                            left: widget.constraints.maxWidth * 0.288,
                            width: widget.constraints.maxWidth * 0.056,
                            top: widget.constraints.maxHeight * 0.053,
                            height: widget.constraints.maxHeight * 0.071,
                            child: widget.ovrMask3 ??
                                SvgPicture.asset(
                                  'assets/images/mask3.svg',
                                  package: 'genius_wallet',
                                  height: widget.constraints.maxHeight *
                                      0.07089895419973545,
                                  width: widget.constraints.maxWidth *
                                      0.055696511570411396,
                                  fit: BoxFit.fill,
                                ),
                          ),
                        ]))),
              ),
              Positioned(
                left: 260.094,
                width: 35.0,
                top: 16.233,
                height: 35.0,
                child: Container(
                    decoration: BoxDecoration(),
                    child: Stack(children: [
                      Positioned(
                        left: 0,
                        width: 35.0,
                        top: 0,
                        height: 35.0,
                        child: Container(
                          height: 35.0,
                          width: 35.0,
                          decoration: BoxDecoration(
                            color: Color(0xff4c4d55),
                            borderRadius:
                                BorderRadius.all(Radius.circular(2.0)),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x2dffffff),
                                spreadRadius: 0.0,
                                blurRadius: 0.0,
                                offset: Offset(0.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 11.0,
                        width: 15.0,
                        top: 9.0,
                        height: 18.0,
                        child: widget.ovrShape ??
                            SvgPicture.asset(
                              'assets/images/shape.svg',
                              package: 'genius_wallet',
                              height: 18.0,
                              width: 15.0,
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
