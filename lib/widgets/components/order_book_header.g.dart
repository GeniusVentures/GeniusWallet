// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/decrease_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:genius_wallet/widgets/components/custom/increase_custom.dart';

class OrderBookHeader extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrOrderBookLabel;
  const OrderBookHeader(
    this.constraints, {
    Key? key,
    this.ovrOrderBookLabel,
  }) : super(key: key);
  @override
  _OrderBookHeader createState() => _OrderBookHeader();
}

class _OrderBookHeader extends State<OrderBookHeader> {
  _OrderBookHeader();

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
                width: 82.0,
                top: 0,
                height: 19.0,
                child: Container(
                    height: 19.0,
                    width: 82.0,
                    child: AutoSizeText(
                      widget.ovrOrderBookLabel ?? 'Order book',
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
                left: 232.0,
                width: 16.0,
                top: 0,
                height: 16.0,
                child: DecreaseCustom(
                    child: SvgPicture.asset(
                  'assets/images/decreasecustom.svg',
                  package: 'genius_wallet',
                  height: 16.0,
                  width: 16.0,
                  fit: BoxFit.none,
                )),
              ),
              Positioned(
                left: 254.0,
                width: 16.0,
                top: 0,
                height: 16.0,
                child: IncreaseCustom(
                    child: SvgPicture.asset(
                  'assets/images/increasecustom.svg',
                  package: 'genius_wallet',
                  height: 16.0,
                  width: 16.0,
                  fit: BoxFit.none,
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
