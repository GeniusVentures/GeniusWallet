// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/percentage_completeness_text_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/percentage_completeness_bar_custom.dart';
import 'package:genius_wallet/widgets/components/custom/update_custom.dart';

class ProfileCompleteness extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovr35;
  const ProfileCompleteness(
    this.constraints, {
    Key? key,
    this.ovr35,
  }) : super(key: key);
  @override
  _ProfileCompleteness createState() => _ProfileCompleteness();
}

class _ProfileCompleteness extends State<ProfileCompleteness> {
  _ProfileCompleteness();

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
                left: 90.0,
                right: 89.0,
                top: 33.0,
                height: 38.0,
                child: PercentageCompletenessTextCustom(
                    child: AutoSizeText(
                  'Your profile is 35% complete',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.30000001192092896,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                )),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.244,
                width: widget.constraints.maxWidth * 0.514,
                top: 93.0,
                height: 16.0,
                child: Center(
                    child: Container(
                        height: 16.0,
                        width: 160.0,
                        child: PercentageCompletenessBarCustom(
                            child: Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(),
                                child: Stack(children: [
                                  Positioned(
                                    left: 0.5,
                                    width: 154.0,
                                    top: 0.2,
                                    height: 15.0,
                                    child: Container(
                                      height: 15.0,
                                      width: 154.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff43444b),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(7.5)),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 100.5,
                                    width: 59.0,
                                    top: 0.2,
                                    height: 15.0,
                                    child: Container(
                                      height: 15.0,
                                      width: 59.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff7ac231),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 120.0,
                                    width: 20.0,
                                    top: 1.541,
                                    height: 12.0,
                                    child: Container(
                                        height: 12.0,
                                        width: 20.0,
                                        child: AutoSizeText(
                                          widget.ovr35 ?? '35%',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.375,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        )),
                                  ),
                                ]))))),
              ),
              Positioned(
                left: 131.0,
                right: 131.0,
                top: 122.0,
                height: 14.0,
                child: UpdateCustom(
                    child: AutoSizeText(
                  'Update',
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
