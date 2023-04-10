// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/desktop/custom/transactionflow_incoming_custom.dart';
import 'package:genius_wallet/widgets/desktop/custom/harmburger_menu_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';

class TransactionflowIncoming extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovr00094LTC;
  final String? ovr1Cs4wu6pu5qCZ35bSLNV;
  final Widget? ovrMask2;
  final Widget? ovrMask4;
  final String? ovr162312dec2018;
  final Widget? ovrCoinImage;
  final Widget? ovrTransactionStatus;
  const TransactionflowIncoming(
    this.constraints, {
    Key? key,
    this.ovr00094LTC,
    this.ovr1Cs4wu6pu5qCZ35bSLNV,
    this.ovrMask2,
    this.ovrMask4,
    this.ovr162312dec2018,
    this.ovrCoinImage,
    this.ovrTransactionStatus,
  }) : super(key: key);
  @override
  _TransactionflowIncoming createState() => _TransactionflowIncoming();
}

class _TransactionflowIncoming extends State<TransactionflowIncoming> {
  _TransactionflowIncoming();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: TransactionflowIncomingCustom(
            child: Stack(children: [
          Positioned(
            left: 0,
            width: 1558.0,
            top: 0,
            height: 76.0,
            child: Container(
                height: 76.0,
                width: 1558.0,
                decoration: BoxDecoration(),
                child: Stack(children: [
                  Positioned(
                    left: 0,
                    width: 1558.0,
                    top: 0,
                    height: 76.0,
                    child: Container(
                      height: 76.0,
                      width: 1558.0,
                      decoration: BoxDecoration(
                        color: Color(0xff2a2b31),
                        borderRadius: BorderRadius.all(Radius.circular(2.0)),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 30.0,
                    width: 4.0,
                    top: 30.0,
                    height: 16.0,
                    child: HarmburgerMenuCustom(
                        child: SvgPicture.asset(
                      'assets/images/harmburgermenucustom.svg',
                      package: 'genius_wallet',
                      height: 16.0,
                      width: 4.0,
                      fit: BoxFit.none,
                    )),
                  ),
                  Positioned(
                    left: 347.0,
                    width: 16.0,
                    top: 32.0,
                    height: 10.667,
                    child: SvgPicture.asset(
                      'assets/images/object.svg',
                      package: 'genius_wallet',
                      height: 10.666748046875,
                      width: 16.0,
                      fit: BoxFit.none,
                    ),
                  ),
                  Positioned(
                    left: 1365.0,
                    width: 121.0,
                    top: 20.0,
                    height: 35.0,
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Container(/** This Symbol was not found **/);
                    }),
                  ),
                  Positioned(
                    left: 216.0,
                    width: 41.978,
                    top: 20.0,
                    height: 35.0,
                    child: widget.ovrCoinImage ??
                        Image.asset(
                          'assets/images/coinimage.png',
                          package: 'genius_wallet',
                          height: 35.0,
                          width: 41.9775390625,
                          fit: BoxFit.none,
                        ),
                  ),
                  Positioned(
                    left: 63.0,
                    width: 124.0,
                    top: 29.0,
                    height: 16.0,
                    child: Container(
                        height: 16.0,
                        width: 124.0,
                        child: AutoSizeText(
                          widget.ovr162312dec2018 ?? '16:23, 12 dec 2018',
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
                    left: 347.0,
                    width: 16.0,
                    top: 32.0,
                    height: 10.667,
                    child: widget.ovrMask4 ??
                        SvgPicture.asset(
                          'assets/images/mask4.svg',
                          package: 'genius_wallet',
                          height: 10.666748046875,
                          width: 16.0,
                          fit: BoxFit.none,
                        ),
                  ),
                  Positioned(
                    left: 30.0,
                    width: 4.0,
                    top: 30.0,
                    height: 16.0,
                    child: widget.ovrMask2 ??
                        Image.asset(
                          'assets/images/mask2.png',
                          package: 'genius_wallet',
                          height: 16.0,
                          width: 4.0,
                          fit: BoxFit.none,
                        ),
                  ),
                  Positioned(
                    left: 374.0,
                    width: 339.0,
                    top: 30.0,
                    height: 16.0,
                    child: Container(
                        height: 16.0,
                        width: 339.0,
                        child: AutoSizeText(
                          widget.ovr1Cs4wu6pu5qCZ35bSLNV ??
                              '1Cs4wu6pu5qCZ35bSLNVzGyEx5N6uzbg9t',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.3499999940395355,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.left,
                        )),
                  ),
                  Positioned(
                    left: 1204.0,
                    width: 132.0,
                    top: 26.0,
                    height: 23.0,
                    child: Container(
                        height: 23.0,
                        width: 132.0,
                        child: AutoSizeText(
                          widget.ovr00094LTC ?? '0.0094 LTC',
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
                ])),
          ),
        ])));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
