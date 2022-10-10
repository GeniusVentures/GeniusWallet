// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/next_month_button_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:genius_wallet/widgets/components/custom/previous_month_button_custom.dart';
import 'package:genius_wallet/widgets/components/custom/add_event_button_custom.dart';

class Monthselector extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrMonth;
  final Widget? ovrMaskNextMonth;
  final Widget? ovrMaskPreviousMonth;
  const Monthselector(
    this.constraints, {
    Key? key,
    this.ovrMonth,
    this.ovrMaskNextMonth,
    this.ovrMaskPreviousMonth,
  }) : super(key: key);
  @override
  _Monthselector createState() => _Monthselector();
}

class _Monthselector extends State<Monthselector> {
  _Monthselector();

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
                width: 107.0,
                top: 5.0,
                height: 19.0,
                child: Container(
                    height: 19.0,
                    width: 107.0,
                    child: AutoSizeText(
                      widget.ovrMonth ?? 'February 2018 ',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 155.0,
                width: 29.0,
                top: 0,
                height: 29.0,
                child: NextMonthButtonCustom(
                    child: Container(
                        decoration: BoxDecoration(),
                        child: Stack(children: [
                          Positioned(
                            left: 0,
                            width: 29.0,
                            top: 0,
                            height: 29.0,
                            child: Container(
                              height: 29.0,
                              width: 29.0,
                              decoration: BoxDecoration(
                                color: Color(0xff2a2b31),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2.0)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12.0,
                            width: 5.0,
                            top: 10.0,
                            height: 9.0,
                            child: widget.ovrMaskNextMonth ??
                                SvgPicture.asset(
                                  'assets/images/masknextmonth.svg',
                                  package: 'genius_wallet',
                                  height: 9.0,
                                  width: 5.0,
                                  fit: BoxFit.none,
                                ),
                          ),
                        ]))),
              ),
              Positioned(
                left: 119.0,
                width: 29.0,
                top: 0,
                height: 29.0,
                child: PreviousMonthButtonCustom(
                    child: Container(
                        decoration: BoxDecoration(),
                        child: Stack(children: [
                          Positioned(
                            left: 0,
                            width: 29.0,
                            top: 0,
                            height: 29.0,
                            child: Container(
                              height: 29.0,
                              width: 29.0,
                              decoration: BoxDecoration(
                                color: Color(0xff2a2b31),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2.0)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 11.0,
                            width: 5.0,
                            top: 10.0,
                            height: 9.0,
                            child: widget.ovrMaskPreviousMonth ??
                                SvgPicture.asset(
                                  'assets/images/maskpreviousmonth.svg',
                                  package: 'genius_wallet',
                                  height: 9.0,
                                  width: 5.0,
                                  fit: BoxFit.none,
                                ),
                          ),
                        ]))),
              ),
              Positioned(
                left: 251.0,
                width: 60.0,
                top: 7.0,
                height: 14.0,
                child: BrannyCustom(
                    child: AutoSizeText(
                  ' Аdd event ',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.30000001192092896,
                    color: Color(0xff7ac231),
                  ),
                  textAlign: TextAlign.center,
                )),
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
