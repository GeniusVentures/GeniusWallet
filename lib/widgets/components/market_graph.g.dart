// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/graph_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MarketGraph extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrCoinToFiat;
  final String? ovrPricePerCoin;
  final String? ovrVolume;
  final String? ovrPercentage;
  const MarketGraph(
    this.constraints, {
    Key? key,
    this.ovrCoinToFiat,
    this.ovrPricePerCoin,
    this.ovrVolume,
    this.ovrPercentage,
  }) : super(key: key);
  @override
  _MarketGraph createState() => _MarketGraph();
}

class _MarketGraph extends State<MarketGraph> {
  _MarketGraph();

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
                left: widget.constraints.maxWidth * 0.068,
                width: widget.constraints.maxWidth * 0.244,
                top: widget.constraints.maxHeight * 0.115,
                height: widget.constraints.maxHeight * 0.073,
                child: Center(
                    child: Container(
                        height: 14.0,
                        width:
                            widget.constraints.maxWidth * 0.24437299035369775,
                        child: AutoSizeText(
                          widget.ovrCoinToFiat ?? 'ETH/USD',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.25714290142059326,
                            color: Color(0xff4c4d55),
                          ),
                          textAlign: TextAlign.left,
                        ))),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.521,
                width: widget.constraints.maxWidth * 0.418,
                top: widget.constraints.maxHeight * 0.089,
                height: widget.constraints.maxHeight * 0.24,
                child: Center(
                    child: Container(
                        height: 46.0,
                        width: widget.constraints.maxWidth * 0.4180064308681672,
                        child: AutoSizeText(
                          widget.ovrPricePerCoin ?? '1,307.96  USD',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.6000000238418579,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.right,
                        ))),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.064,
                width: widget.constraints.maxWidth * 0.447,
                top: widget.constraints.maxHeight * 0.807,
                height: widget.constraints.maxHeight * 0.083,
                child: Center(
                    child: Container(
                        height: 16.0,
                        width:
                            widget.constraints.maxWidth * 0.44694533762057875,
                        child: AutoSizeText(
                          widget.ovrVolume ?? 'Volume: 126,478 LTC',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.30000001192092896,
                            color: Color(0xff606166),
                          ),
                          textAlign: TextAlign.left,
                        ))),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.823,
                width: widget.constraints.maxWidth * 0.113,
                top: widget.constraints.maxHeight * 0.813,
                height: widget.constraints.maxHeight * 0.073,
                child: Center(
                    child: Container(
                        height: 14.0,
                        width:
                            widget.constraints.maxWidth * 0.11254019292604502,
                        child: AutoSizeText(
                          widget.ovrPercentage ?? '1.93%',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.44999998807907104,
                            color: Color(0xff7ac231),
                          ),
                          textAlign: TextAlign.right,
                        ))),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.071,
                width: widget.constraints.maxWidth * 0.855,
                top: widget.constraints.maxHeight * 0.359,
                height: widget.constraints.maxHeight * 0.411,
                child: GraphCustom(
                    child: SvgPicture.asset(
                  'assets/images/graphcustom.svg',
                  package: 'genius_wallet',
                  height: widget.constraints.maxHeight * 0.4114583333333333,
                  width: widget.constraints.maxWidth * 0.8553054662379421,
                  fit: BoxFit.fill,
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
