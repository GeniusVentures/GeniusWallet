// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/desktop/custom/support_button_custom.dart';
import 'package:genius_wallet/widgets/desktop/custom/add_button_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:genius_wallet/widgets/desktop/custom/harmburger_menu_custom.dart';
import 'package:genius_wallet/widgets/desktop/custom/profile_picture_button_custom.dart';
import 'package:genius_wallet/widgets/desktop/search_bar.g.dart';
import 'package:genius_wallet/widgets/desktop/support_button.g.dart';
import 'package:genius_wallet/widgets/desktop/add_button.g.dart';
import 'package:genius_wallet/widgets/desktop/harmburger_menu.g.dart';
import 'package:genius_wallet/widgets/desktop/profile_picture_button.g.dart';

class DesktopAppbar extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrDashboard;
  final String? ovrNikitaResheteev;
  final Widget? ovrSearchBar;
  const DesktopAppbar(
    this.constraints, {
    Key? key,
    this.ovrDashboard,
    this.ovrNikitaResheteev,
    this.ovrSearchBar,
  }) : super(key: key);
  @override
  _DesktopAppbar createState() => _DesktopAppbar();
}

class _DesktopAppbar extends State<DesktopAppbar> {
  _DesktopAppbar();

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
                width: widget.constraints.maxWidth * 0.076,
                top: widget.constraints.maxHeight * 0.135,
                height: widget.constraints.maxHeight * 0.757,
                child: Container(
                    height: widget.constraints.maxHeight * 0.7567567567567568,
                    width: widget.constraints.maxWidth * 0.07603092783505154,
                    child: AutoSizeText(
                      widget.ovrDashboard ?? 'Dashboard',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 24.0,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.898,
                width: widget.constraints.maxWidth * 0.072,
                top: widget.constraints.maxHeight * 0.27,
                height: widget.constraints.maxHeight * 0.432,
                child: Container(
                    height: widget.constraints.maxHeight * 0.43243243243243246,
                    width: widget.constraints.maxWidth * 0.07216494845360824,
                    child: AutoSizeText(
                      widget.ovrNikitaResheteev ?? 'Nikita Resheteev',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.191,
                width: widget.constraints.maxWidth * 0.158,
                top: widget.constraints.maxHeight * 0.054,
                height: widget.constraints.maxHeight * 0.946,
                child: LayoutBuilder(builder: (context, constraints) {
                  return SearchBar(
                    constraints,
                    ovrSearch: 'Search…',
                    ovrMask: Image.asset(
                      'assets/images/mask.png',
                      package: 'genius_wallet',
                      height: widget.constraints.maxHeight * 0.4727024387668919,
                      width: widget.constraints.maxWidth * 0.011269480911726804,
                      fit: BoxFit.fill,
                    ),
                  );
                }),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.76,
                width: widget.constraints.maxWidth * 0.062,
                top: 0,
                height: widget.constraints.maxHeight * 0.946,
                child: SupportButtonCustom(
                    child: LayoutBuilder(builder: (context, constraints) {
                  return SupportButton(
                    constraints,
                    ovrSupport: 'Support',
                    ovrMask: Image.asset(
                      'assets/images/mask.png',
                      package: 'genius_wallet',
                      height: widget.constraints.maxHeight * 0.3783783783783784,
                      width: widget.constraints.maxWidth * 0.00902061855670103,
                      fit: BoxFit.fill,
                    ),
                    ovrMask2: Image.asset(
                      'assets/images/mask.png',
                      package: 'genius_wallet',
                      height: widget.constraints.maxHeight * 0.3783783783783784,
                      width: widget.constraints.maxWidth * 0.00902061855670103,
                      fit: BoxFit.fill,
                    ),
                  );
                })),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.829,
                width: widget.constraints.maxWidth * 0.023,
                top: 0,
                height: widget.constraints.maxHeight * 0.946,
                child: AddButtonCustom(
                    child: LayoutBuilder(builder: (context, constraints) {
                  return AddButton(
                    constraints,
                    ovrMask: SvgPicture.asset(
                      'assets/images/mask.svg',
                      package: 'genius_wallet',
                      height: widget.constraints.maxHeight * 0.3783783783783784,
                      width: widget.constraints.maxWidth * 0.00902061855670103,
                      fit: BoxFit.fill,
                    ),
                  );
                })),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.876,
                width: widget.constraints.maxWidth * 0.012,
                top: widget.constraints.maxHeight * 0.324,
                height: widget.constraints.maxHeight * 0.324,
                child: HarmburgerMenuCustom(
                    child: LayoutBuilder(builder: (context, constraints) {
                  return HarmburgerMenu(
                    constraints,
                    ovrMask: Image.asset(
                      'assets/images/mask.png',
                      package: 'genius_wallet',
                      height:
                          widget.constraints.maxHeight * 0.32432432432432434,
                      width: widget.constraints.maxWidth * 0.011597938144329897,
                      fit: BoxFit.fill,
                    ),
                  );
                })),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.977,
                width: widget.constraints.maxWidth * 0.023,
                top: widget.constraints.maxHeight * 0.027,
                height: widget.constraints.maxHeight * 0.946,
                child: ProfilePictureButtonCustom(
                    child: LayoutBuilder(builder: (context, constraints) {
                  return ProfilePictureButton(
                    constraints,
                    ovrMask: Image.asset(
                      'assets/images/mask.png',
                      package: 'genius_wallet',
                      height:
                          widget.constraints.maxHeight * 0.43243243243243246,
                      width: widget.constraints.maxWidth * 0.010309278350515464,
                      fit: BoxFit.fill,
                    ),
                    ovrMask2: Image.asset(
                      'assets/images/mask.png',
                      package: 'genius_wallet',
                      height:
                          widget.constraints.maxHeight * 0.43243243243243246,
                      width: widget.constraints.maxWidth * 0.010309278350515464,
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
