// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/navbar_group22.g.dart';

class Appbar extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrnavbarGroup22;
  const Appbar(
    this.constraints, {
    Key? key,
    this.ovrnavbarGroup22,
  }) : super(key: key);
  @override
  _Appbar createState() => _Appbar();
}

class _Appbar extends State<Appbar> {
  _Appbar();

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
            child: LayoutBuilder(builder: (context, constraints) {
              return NavbarGroup22(
                constraints,
                ovrChatbubbles: Image.asset(
                  'assets/images/chatbubbles.png',
                  package: 'genius_wallet',
                  height: widget.constraints.maxHeight * 0.4878048780487805,
                  width: widget.constraints.maxWidth * 0.06430868167202572,
                  fit: BoxFit.fill,
                ),
                ovrimage1: Image.asset(
                  'assets/images/image1.png',
                  package: 'genius_wallet',
                  height: widget.constraints.maxHeight * 0.926829268292683,
                  width: widget.constraints.maxWidth * 0.5610932475884244,
                  fit: BoxFit.fill,
                ),
              );
            }),
          ),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
