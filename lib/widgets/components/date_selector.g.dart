// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/date_selector_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class DateSelector extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrfrom;
  final String? ovrOct132017;
  final String? ovrTo;
  final String? ovrEndDate;
  const DateSelector(
    this.constraints, {
    Key? key,
    this.ovrfrom,
    this.ovrOct132017,
    this.ovrTo,
    this.ovrEndDate,
  }) : super(key: key);
  @override
  _DateSelector createState() => _DateSelector();
}

class _DateSelector extends State<DateSelector> {
  _DateSelector();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: DateSelectorCustom(
            child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: Stack(children: [
              Positioned(
                left: 0,
                width: 38.0,
                top: 8.0,
                height: 13.0,
                child: Container(
                    height: 13.0,
                    width: 38.0,
                    child: AutoSizeText(
                      widget.ovrfrom ?? 'from',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4124999940395355,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
              Positioned(
                left: 42.0,
                width: 90.0,
                top: 0,
                height: 29.0,
                child: Container(
                    decoration: BoxDecoration(),
                    child: Stack(children: [
                      Positioned(
                        left: 0,
                        width: 90.0,
                        top: 0,
                        height: 29.0,
                        child: Container(
                          height: 29.0,
                          width: 90.0,
                          decoration: BoxDecoration(
                            color: Color(0xff2a2b31),
                            borderRadius:
                                BorderRadius.all(Radius.circular(2.0)),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 4.0,
                        width: 82.0,
                        top: 8.0,
                        height: 14.0,
                        child: Container(
                            height: 14.0,
                            width: 82.0,
                            child: AutoSizeText(
                              widget.ovrOct132017 ?? 'Oct 13, 2017',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.30000001192092896,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.left,
                            )),
                      ),
                    ])),
              ),
              Positioned(
                left: 144.0,
                width: 29.0,
                top: 8.0,
                height: 13.0,
                child: Container(
                    height: 13.0,
                    width: 29.0,
                    child: AutoSizeText(
                      widget.ovrTo ?? 'To',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4124999940395355,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
              Positioned(
                left: 181.0,
                width: 90.0,
                top: 0,
                height: 29.0,
                child: Container(
                    decoration: BoxDecoration(),
                    child: Stack(children: [
                      Positioned(
                        left: 0,
                        width: 90.0,
                        top: 0,
                        height: 29.0,
                        child: Container(
                          height: 29.0,
                          width: 90.0,
                          decoration: BoxDecoration(
                            color: Color(0xff2a2b31),
                            borderRadius:
                                BorderRadius.all(Radius.circular(2.0)),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 5.0,
                        width: 81.0,
                        top: 8.0,
                        height: 14.0,
                        child: Container(
                            height: 14.0,
                            width: 81.0,
                            child: AutoSizeText(
                              widget.ovrEndDate ?? 'Dec 13, 2017',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.30000001192092896,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.left,
                            )),
                      ),
                    ])),
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
