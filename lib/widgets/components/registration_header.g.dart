// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/genius_back_button_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:genius_wallet/widgets/components/genius_back_button.g.dart';

class RegistrationHeader extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrSubtitle;
  final String? ovrTitle;
  const RegistrationHeader(
    this.constraints, {
    Key? key,
    this.ovrSubtitle,
    this.ovrTitle,
  }) : super(key: key);
  @override
  _RegistrationHeader createState() => _RegistrationHeader();
}

class _RegistrationHeader extends State<RegistrationHeader> {
  _RegistrationHeader();

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
                height: 190.0,
                child: Container(
                  height: 190.0,
                  width: widget.constraints.maxWidth * 1.0,
                  decoration: BoxDecoration(
                    color: Color(0xff0068ef),
                  ),
                ),
              ),
              Positioned(
                left: 30.0,
                right: 30.0,
                top: 100.0,
                height: 32.0,
                child: Container(
                    height: 32.0,
                    width: widget.constraints.maxWidth * 0.84,
                    child: AutoSizeText(
                      widget.ovrSubtitle ??
                          'In the next step you will see 12 words that allows you to recover a wallet.',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.13750000298023224,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
              Positioned(
                left: 74.0,
                right: 74.0,
                top: 57.0,
                height: 23.0,
                child: Container(
                    height: 23.0,
                    width: widget.constraints.maxWidth * 0.6053333333333333,
                    child: AutoSizeText(
                      widget.ovrTitle ?? 'Back up your wallet now!',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.13750000298023224,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
              Positioned(
                left: 30.0,
                width: 10.0,
                top: 22.0,
                height: 18.0,
                child: GeniusBackButtonCustom(
                    child: LayoutBuilder(builder: (context, constraints) {
                  return GeniusBackButton(
                    constraints,
                    ovrWhiteArrowBack: SvgPicture.asset(
                      'assets/images/whitearrowback.svg',
                      package: 'genius_wallet',
                      height:
                          widget.constraints.maxHeight * 0.09473684210526316,
                      width: widget.constraints.maxWidth * 0.02666666666666667,
                      fit: BoxFit.fill,
                    ),
                  );
                })),
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
