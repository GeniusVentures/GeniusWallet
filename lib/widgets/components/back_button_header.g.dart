// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/back_button_dashboard.g.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/back_button_dashboard_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BackButtonHeader extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrTitle;
  const BackButtonHeader(
    this.constraints, {
    Key? key,
    this.ovrTitle,
  }) : super(key: key);
  @override
  _BackButtonHeader createState() => _BackButtonHeader();
}

class _BackButtonHeader extends State<BackButtonHeader> {
  _BackButtonHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: GeniusWalletColors.grayPrimary),
        child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 5,
            height: widget.constraints.maxHeight * 1.0,
            child: Stack(children: [
              Positioned(
                left: 88.0,
                right: 88.0,
                top: 10.0,
                child: Container(
                    width: widget.constraints.maxWidth * 0.43769968051118213,
                    child: AutoSizeText(
                      widget.ovrTitle ?? 'Send Bitcoin',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
              Positioned(
                left: 0,
                width: 79.0,
                top: 5,
                height: 35.0,
                child: BackButtonDashboardCustom(
                    child: LayoutBuilder(builder: (context, constraints) {
                  return BackButtonDashboard(
                    constraints,
                    ovrBack: 'Back',
                    ovrWhiteArrowLeft: SvgPicture.asset(
                      'assets/images/whitearrowleft.svg',
                      package: 'genius_wallet',
                      height: widget.constraints.maxHeight * 0.2571428571428571,
                      width: widget.constraints.maxWidth * 0.01597444089456869,
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
