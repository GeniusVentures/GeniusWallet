// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/nickname_logic.dart';
import 'package:genius_wallet/widgets/components/nickname_widget.g.dart';
import 'package:genius_wallet/widgets/components/custom/email_logic.dart';
import 'package:genius_wallet/widgets/components/email_widget.g.dart';
import 'package:genius_wallet/widgets/components/custom/first_name_logic.dart';
import 'package:genius_wallet/widgets/components/first_name_widget.g.dart';
import 'package:genius_wallet/widgets/components/custom/last_name_logic.dart';
import 'package:genius_wallet/widgets/components/last_name_widget.g.dart';
import 'package:genius_wallet/widgets/components/custom/month_selector_custom.dart';
import 'package:genius_wallet/widgets/components/custom/day_selector_custom.dart';
import 'package:genius_wallet/widgets/components/custom/year_selector_custom.dart';

class ProfileInfoForm extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrArrowSelectorVertical;
  final String? ovrYear;
  final Widget? ovrArrowSelectorVertical2;
  final String? ovrDay;
  final Widget? ovrArrowSelectorVertical3;
  final String? ovrNikita;
  final String? ovrDateofbirth;
  final String? ovrLastNamehinttext;
  final String? ovrFirstNamehinttext;
  final String? ovrLegalName;
  final String? ovrYourpersonalinform;
  final String? ovrPersonalDetail;
  final String? ovrEmailhinttext;
  final String? ovrEmail;
  final String? ovrNicknamehinttext;
  final String? ovrThisnamewillbepa;
  final String? ovrNickName;
  const ProfileInfoForm(
    this.constraints, {
    Key? key,
    this.ovrArrowSelectorVertical,
    this.ovrYear,
    this.ovrArrowSelectorVertical2,
    this.ovrDay,
    this.ovrArrowSelectorVertical3,
    this.ovrNikita,
    this.ovrDateofbirth,
    this.ovrLastNamehinttext,
    this.ovrFirstNamehinttext,
    this.ovrLegalName,
    this.ovrYourpersonalinform,
    this.ovrPersonalDetail,
    this.ovrEmailhinttext,
    this.ovrEmail,
    this.ovrNicknamehinttext,
    this.ovrThisnamewillbepa,
    this.ovrNickName,
  }) : super(key: key);
  @override
  _ProfileInfoForm createState() => _ProfileInfoForm();
}

class _ProfileInfoForm extends State<ProfileInfoForm> {
  _ProfileInfoForm();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: Stack(children: [
          Positioned(
            left: 0,
            width: 312.0,
            top: 0,
            height: 603.0,
            child: Container(
                decoration: BoxDecoration(),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          height: 111.0,
                          width: 311.0,
                          decoration: BoxDecoration(),
                          child: Stack(children: [
                            Positioned(
                              left: 0,
                              width: 94.0,
                              top: 0,
                              height: 19.0,
                              child: Container(
                                  height: 19.0,
                                  width: 94.0,
                                  child: AutoSizeText(
                                    widget.ovrNickName ?? 'Nickname',
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
                              left: 0,
                              width: 245.0,
                              top: 26.0,
                              height: 28.0,
                              child: Container(
                                  height: 28.0,
                                  width: 245.0,
                                  child: AutoSizeText(
                                    widget.ovrThisnamewillbepa ??
                                        'This name will be part of your public profile.',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.30000001192092896,
                                      color: Color(0xff85858a),
                                    ),
                                    textAlign: TextAlign.left,
                                  )),
                            ),
                            Positioned(
                              left: 0,
                              width: 311.0,
                              top: 71.0,
                              height: 40.0,
                              child: NicknameWidget(
                                logic: NicknameLogic(context),
                              ),
                            ),
                          ])),
                      SizedBox(
                        height: 42.0,
                      ),
                      Container(
                          height: 72.0,
                          width: 311.0,
                          decoration: BoxDecoration(),
                          child: Stack(children: [
                            Positioned(
                              left: 0,
                              width: 44.0,
                              top: 0,
                              height: 14.0,
                              child: Container(
                                  height: 14.0,
                                  width: 44.0,
                                  child: AutoSizeText(
                                    widget.ovrEmail ?? 'Email',
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
                            Positioned(
                              left: 0,
                              width: 311.0,
                              top: 32.0,
                              height: 40.0,
                              child: EmailWidget(
                                logic: EmailLogic(context),
                              ),
                            ),
                          ])),
                      SizedBox(
                        height: 42.0,
                      ),
                      Container(
                          height: 54.0,
                          width: 245.0,
                          decoration: BoxDecoration(),
                          child: Stack(children: [
                            Positioned(
                              left: 0,
                              width: 149.0,
                              top: 0,
                              height: 19.0,
                              child: Container(
                                  height: 19.0,
                                  width: 149.0,
                                  child: AutoSizeText(
                                    widget.ovrPersonalDetail ??
                                        'Personal Details',
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
                              left: 0,
                              width: 245.0,
                              top: 26.0,
                              height: 28.0,
                              child: Container(
                                  height: 28.0,
                                  width: 245.0,
                                  child: AutoSizeText(
                                    widget.ovrYourpersonalinform ??
                                        'Your personal information is never shown to other users.',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.30000001192092896,
                                      color: Color(0xff85858a),
                                    ),
                                    textAlign: TextAlign.left,
                                  )),
                            ),
                          ])),
                      SizedBox(
                        height: 42.0,
                      ),
                      Container(
                          height: 133.0,
                          width: 312.0,
                          decoration: BoxDecoration(),
                          child: Stack(children: [
                            Positioned(
                              left: 0,
                              width: 81.0,
                              top: 3.0,
                              height: 18.0,
                              child: Container(
                                  height: 18.0,
                                  width: 81.0,
                                  child: AutoSizeText(
                                    widget.ovrLegalName ?? 'Legal Name',
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
                            Positioned(
                              left: 1.0,
                              width: 311.0,
                              top: 33.0,
                              height: 40.0,
                              child: FirstNameWidget(
                                logic: FirstNameLogic(context),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              width: 311.0,
                              top: 93.0,
                              height: 40.0,
                              child: LastNameWidget(
                                logic: LastNameLogic(context),
                              ),
                            ),
                          ])),
                      SizedBox(
                        height: 42.0,
                      ),
                      Container(
                          height: 65.0,
                          width: 311.0,
                          decoration: BoxDecoration(),
                          child: Stack(children: [
                            Positioned(
                              left: 0,
                              width: 91.0,
                              top: 0,
                              height: 14.0,
                              child: Container(
                                  height: 14.0,
                                  width: 91.0,
                                  child: AutoSizeText(
                                    widget.ovrDateofbirth ?? 'Date of birth',
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
                            Positioned(
                              left: 0,
                              width: 311.0,
                              top: 25.0,
                              height: 40.0,
                              child: Container(
                                  decoration: BoxDecoration(),
                                  child: Stack(children: [
                                    Positioned(
                                      left: 0,
                                      width: 115.0,
                                      top: 0,
                                      height: 40.0,
                                      child: MonthSelectorCustom(
                                          child: Container(
                                              decoration: BoxDecoration(),
                                              child: Stack(children: [
                                                Positioned(
                                                  left: 0,
                                                  width: 115.0,
                                                  top: 0,
                                                  height: 40.0,
                                                  child: Container(
                                                    height: 40.0,
                                                    width: 115.0,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xff2a2b31),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  2.0)),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 23.0,
                                                  width: 51.0,
                                                  top: 12.0,
                                                  height: 14.0,
                                                  child: Container(
                                                      height: 14.0,
                                                      width: 51.0,
                                                      child: AutoSizeText(
                                                        widget.ovrNikita ??
                                                            'Month',
                                                        style: TextStyle(
                                                          fontFamily: 'Roboto',
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          letterSpacing:
                                                              0.30000001192092896,
                                                          color:
                                                              Color(0xff85858a),
                                                        ),
                                                        textAlign:
                                                            TextAlign.left,
                                                      )),
                                                ),
                                                Positioned(
                                                  left: 95.0,
                                                  width: 7.0,
                                                  top: 12.0,
                                                  height: 14.0,
                                                  child: widget
                                                          .ovrArrowSelectorVertical3 ??
                                                      Image.asset(
                                                        'assets/images/arrowselectorvertical3.png',
                                                        package:
                                                            'genius_wallet',
                                                        height: 14.0,
                                                        width: 7.0,
                                                        fit: BoxFit.none,
                                                      ),
                                                ),
                                              ]))),
                                    ),
                                    Positioned(
                                      left: 132.0,
                                      width: 78.0,
                                      top: 0,
                                      height: 40.0,
                                      child: DaySelectorCustom(
                                          child: Container(
                                              decoration: BoxDecoration(),
                                              child: Stack(children: [
                                                Positioned(
                                                  left: 0,
                                                  width: 78.0,
                                                  top: 0,
                                                  height: 40.0,
                                                  child: Container(
                                                    height: 40.0,
                                                    width: 78.0,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xff2a2b31),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  2.0)),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 16.0,
                                                  width: 36.0,
                                                  top: 13.0,
                                                  height: 14.0,
                                                  child: Container(
                                                      height: 14.0,
                                                      width: 36.0,
                                                      child: AutoSizeText(
                                                        widget.ovrDay ?? 'Day',
                                                        style: TextStyle(
                                                          fontFamily: 'Roboto',
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          letterSpacing:
                                                              0.30000001192092896,
                                                          color:
                                                              Color(0xff85858a),
                                                        ),
                                                        textAlign:
                                                            TextAlign.left,
                                                      )),
                                                ),
                                                Positioned(
                                                  left: 58.0,
                                                  width: 7.0,
                                                  top: 12.0,
                                                  height: 14.0,
                                                  child: widget
                                                          .ovrArrowSelectorVertical2 ??
                                                      Image.asset(
                                                        'assets/images/arrowselectorvertical2.png',
                                                        package:
                                                            'genius_wallet',
                                                        height: 14.0,
                                                        width: 7.0,
                                                        fit: BoxFit.none,
                                                      ),
                                                ),
                                              ]))),
                                    ),
                                    Positioned(
                                      left: 227.0,
                                      width: 84.0,
                                      top: 0,
                                      height: 40.0,
                                      child: YearSelectorCustom(
                                          child: Container(
                                              decoration: BoxDecoration(),
                                              child: Stack(children: [
                                                Positioned(
                                                  left: 0,
                                                  width: 84.0,
                                                  top: 0,
                                                  height: 40.0,
                                                  child: Container(
                                                    height: 40.0,
                                                    width: 84.0,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xff2a2b31),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  2.0)),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 16.0,
                                                  width: 40.0,
                                                  top: 13.0,
                                                  height: 14.0,
                                                  child: Container(
                                                      height: 14.0,
                                                      width: 40.0,
                                                      child: AutoSizeText(
                                                        widget.ovrYear ??
                                                            'Year',
                                                        style: TextStyle(
                                                          fontFamily: 'Roboto',
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          letterSpacing:
                                                              0.30000001192092896,
                                                          color:
                                                              Color(0xff85858a),
                                                        ),
                                                        textAlign:
                                                            TextAlign.left,
                                                      )),
                                                ),
                                                Positioned(
                                                  left: 64.0,
                                                  width: 7.0,
                                                  top: 12.0,
                                                  height: 14.0,
                                                  child: widget
                                                          .ovrArrowSelectorVertical ??
                                                      Image.asset(
                                                        'assets/images/arrowselectorvertical.png',
                                                        package:
                                                            'genius_wallet',
                                                        height: 14.0,
                                                        width: 7.0,
                                                        fit: BoxFit.none,
                                                      ),
                                                ),
                                              ]))),
                                    ),
                                  ])),
                            ),
                          ])),
                    ])),
          ),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
