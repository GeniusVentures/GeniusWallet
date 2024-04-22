// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/custom/alerts_custom.dart';
import 'package:genius_wallet/widgets/components/custom/hamburger_menu_icon_custom.dart';

class GeniusAppbar extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrGeniusAppbarLogo;
  final Widget? ovrChatbubbles;
  const GeniusAppbar(
    this.constraints, {
    Key? key,
    this.ovrGeniusAppbarLogo,
    this.ovrChatbubbles,
  }) : super(key: key);
  @override
  _GeniusAppbar createState() => _GeniusAppbar();
}

class _GeniusAppbar extends State<GeniusAppbar> {
  _GeniusAppbar();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: Stack(children: [
          Container(
              decoration: BoxDecoration(),
              child: Stack(children: [
                Positioned(
                  right: 45.0,
                  width: 41.0,
                  top: 0,
                  height: 41.0,
                  child: AlertsCustom(
                      child: Container(
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(),
                          child: Stack(children: [
                            const Positioned(
                              left: 0,
                              width: 34.0,
                              top: 7.0,
                              height: 34.0,
                              child: SizedBox(
                                height: 34.0,
                                width: 34.0,
                              ),
                            ),
                            Positioned(
                              left: 7.0,
                              width: 20.0,
                              top: 14.0,
                              height: 20.0,
                              child: widget.ovrChatbubbles ??
                                  Image.asset(
                                    'assets/images/chat_bubble.png',
                                    height: 20.0,
                                    width: 20.0,
                                    fit: BoxFit.none,
                                  ),
                            ),
                          ]))),
                ),
                Positioned(
                  right: 0,
                  width: 36.6,
                  top: 16.0,
                  height: 14.5,
                  child: HamburgerMenuIconCustom(
                      child: Container(
                          decoration: BoxDecoration(),
                          child: Stack(children: [
                            Positioned(
                              right: 0,
                              width: 24.6,
                              top: 0,
                              height: 1.5,
                              child: Container(
                                height: 1.5,
                                width: 24.599609375,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              width: 8.6,
                              top: 13.0,
                              height: 1.5,
                              child: Container(
                                height: 1.5,
                                width: 8.599609375,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              width: 36.6,
                              top: 7.0,
                              height: 1.5,
                              child: Container(
                                height: 1.5,
                                width: 36.599609375,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ]))),
                ),
                Positioned(
                  left: 2,
                  width: 38.0,
                  top: 5.0,
                  height: 38.0,
                  child: widget.ovrGeniusAppbarLogo ??
                      Image.asset(
                        'assets/images/geniusappbarlogo.png',
                        package: 'genius_wallet',
                        height: 38.0,
                        width: 38.0,
                        fit: BoxFit.none,
                      ),
                ),
              ])),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
