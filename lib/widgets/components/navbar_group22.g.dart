// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';

class NavbarGroup22 extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrChatbubbles;
  final Widget? ovrimage1;
  const NavbarGroup22(
    this.constraints, {
    Key? key,
    this.ovrChatbubbles,
    this.ovrimage1,
  }) : super(key: key);
  @override
  _NavbarGroup22 createState() => _NavbarGroup22();
}

class _NavbarGroup22 extends State<NavbarGroup22> {
  _NavbarGroup22();

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
            child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(),
                child: Stack(children: [
                  Positioned(
                    left: widget.constraints.maxWidth * 0.723,
                    width: widget.constraints.maxWidth * 0.109,
                    top: widget.constraints.maxHeight * 0.171,
                    height: widget.constraints.maxHeight * 0.829,
                    child: Container(
                      height: widget.constraints.maxHeight * 0.8292682926829268,
                      width: widget.constraints.maxWidth * 0.10932475884244373,
                      decoration: BoxDecoration(
                        color: Color(0xff4c4d55),
                        borderRadius: BorderRadius.all(Radius.circular(2.0)),
                      ),
                    ),
                  ),
                  Positioned(
                    left: widget.constraints.maxWidth * 0.746,
                    width: widget.constraints.maxWidth * 0.064,
                    top: widget.constraints.maxHeight * 0.341,
                    height: widget.constraints.maxHeight * 0.488,
                    child: widget.ovrChatbubbles ??
                        Image.asset(
                          'assets/images/chatbubbles.png',
                          package: 'genius_wallet',
                          height:
                              widget.constraints.maxHeight * 0.4878048780487805,
                          width:
                              widget.constraints.maxWidth * 0.06430868167202572,
                          fit: BoxFit.fill,
                        ),
                  ),
                  Positioned(
                    left: widget.constraints.maxWidth * 0.882,
                    width: widget.constraints.maxWidth * 0.118,
                    top: widget.constraints.maxHeight * 0.39,
                    height: widget.constraints.maxHeight * 0.354,
                    child: Container(
                        decoration: BoxDecoration(),
                        child: Stack(children: [
                          Positioned(
                            left: widget.constraints.maxWidth * 0.039,
                            width: widget.constraints.maxWidth * 0.079,
                            top: 0,
                            height: widget.constraints.maxHeight * 0.037,
                            child: Container(
                              height: widget.constraints.maxHeight *
                                  0.036585365853658534,
                              width: widget.constraints.maxWidth *
                                  0.07909959995478295,
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Positioned(
                            left: widget.constraints.maxWidth * 0.09,
                            width: widget.constraints.maxWidth * 0.028,
                            top: widget.constraints.maxHeight * 0.317,
                            height: widget.constraints.maxHeight * 0.037,
                            child: Container(
                              height: widget.constraints.maxHeight *
                                  0.036585365853658534,
                              width: widget.constraints.maxWidth *
                                  0.02765265461716238,
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            width: widget.constraints.maxWidth * 0.118,
                            top: widget.constraints.maxHeight * 0.171,
                            height: widget.constraints.maxHeight * 0.037,
                            child: Container(
                              height: widget.constraints.maxHeight *
                                  0.036585365853658534,
                              width: widget.constraints.maxWidth *
                                  0.11768480895799839,
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ])),
                  ),
                  Positioned(
                    left: 0,
                    width: widget.constraints.maxWidth * 0.113,
                    top: widget.constraints.maxHeight * 0.024,
                    height: widget.constraints.maxHeight * 0.927,
                    child: Container(
                        decoration: BoxDecoration(),
                        child: Stack(children: [
                          Positioned(
                            left: 0,
                            width: widget.constraints.maxWidth * 0.113,
                            top: 0,
                            height: widget.constraints.maxHeight * 0.927,
                            child: Container(
                              height: widget.constraints.maxHeight *
                                  0.926829268292683,
                              width: widget.constraints.maxWidth *
                                  0.11254019292604502,
                              decoration: BoxDecoration(
                                color: Color(0xffd9d9d9),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            width: widget.constraints.maxWidth * 0.561,
                            top: 0,
                            height: widget.constraints.maxHeight * 0.927,
                            child: widget.ovrimage1 ??
                                Image.asset(
                                  'assets/images/image1.png',
                                  package: 'genius_wallet',
                                  height: widget.constraints.maxHeight *
                                      0.926829268292683,
                                  width: widget.constraints.maxWidth *
                                      0.5610932475884244,
                                  fit: BoxFit.fill,
                                ),
                          ),
                        ])),
                  ),
                ])),
          ),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
