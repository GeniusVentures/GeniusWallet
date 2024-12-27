import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/widgets/components/custom/graph_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MarketGraph extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrPriceCurrency;
  final String? ovrCoinToFiat;
  final String? ovrPricePerCoin;
  final String? ovrVolume;
  final String? ovrPercentage;
  const MarketGraph(
    this.constraints, {
    Key? key,
    this.ovrPriceCurrency,
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
            width: widget.constraints.maxWidth,
            top: 0,
            height: widget.constraints.maxHeight,
            child: Stack(children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  height: widget.constraints.maxHeight,
                  width: widget.constraints.maxWidth,
                  decoration: const BoxDecoration(
                    color: GeniusWalletColors.deepBlueCardColor,
                    borderRadius: BorderRadius.all(
                        Radius.circular(GeniusWalletConsts.borderRadiusCard)),
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
                        height: 30.0,
                        width:
                            widget.constraints.maxWidth * 0.24437299035369775,
                        child: AutoSizeText(
                          widget.ovrCoinToFiat ?? 'ETH/USD',
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.3,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.left,
                        ))),
              ),
              Positioned(
                right: 20,
                top: widget.constraints.maxHeight * 0.1,
                height: widget.constraints.maxHeight * 0.24,
                child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 5,
                    children: [
                      AutoSizeText(
                        widget.ovrPricePerCoin ?? '1,307.96',
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 24.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      Text(
                        widget.ovrPriceCurrency ?? 'USD',
                        style: const TextStyle(
                            color: GeniusWalletColors.gray500,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .25),
                      )
                    ]),
              ),
              Positioned(
                left: 20,
                bottom: 20,
                width: widget.constraints.maxWidth - 40,
                child: Center(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                      AutoSizeText(
                        widget.ovrVolume ?? 'Volume: 126,478 LTC',
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.25,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      AutoSizeText(
                        widget.ovrPercentage ?? '1.93%',
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: Color(0xff7ac231),
                        ),
                        textAlign: TextAlign.right,
                      )
                    ])),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.071,
                width: widget.constraints.maxWidth * 0.855,
                top: widget.constraints.maxHeight * 0.359,
                height: widget.constraints.maxHeight * 0.411,
                child: Container(
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, boxShadow: [
                      BoxShadow(
                        color: GeniusWalletColors.lightGreenPrimary
                            .withOpacity(.8),
                        spreadRadius: 2,
                        blurRadius: 90,
                      )
                    ]),
                    child: GraphCustom(
                        child: SvgPicture.asset(
                      'assets/images/graphcustom.svg',
                      package: 'genius_wallet',
                      height: widget.constraints.maxHeight * 0.4114583333333333,
                      width: widget.constraints.maxWidth * 0.8553054662379421,
                      fit: BoxFit.fill,
                    ))),
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
