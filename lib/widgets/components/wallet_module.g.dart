import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/app/utils/wallet_utils.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';
import 'package:genius_wallet/theme/genius_wallet_text.dart';
import 'package:genius_wallet/widgets/components/wallet_type_icon.dart';

class WalletModule extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrWalletBalance;
  final String? walletName;
  final String? ovrLastTransactionID;
  final String? ovrLastTransactionValue;
  final String? ovrTimestamp;
  final Widget? ovrTrendLine;
  final String? ovrCoinSymbol;
  final String? walletAddress;
  final WalletType? walletType;
  const WalletModule(this.constraints,
      {Key? key,
      this.ovrWalletBalance,
      this.walletName,
      this.ovrLastTransactionID,
      this.ovrLastTransactionValue,
      this.ovrTimestamp,
      this.ovrTrendLine,
      this.ovrCoinSymbol,
      this.walletAddress,
      this.walletType})
      : super(key: key);
  @override
  _WalletModule createState() => _WalletModule();
}

class _WalletModule extends State<WalletModule> {
  _WalletModule();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding:
            const EdgeInsets.only(top: 24, bottom: 40, left: 20, right: 20),
        height: widget.constraints.maxWidth,
        width: widget.constraints.maxWidth,
        decoration: const BoxDecoration(
          color: GeniusWalletColors.deepBlueCardColor,
          borderRadius: BorderRadius.all(
              Radius.circular(GeniusWalletConsts.borderRadiusCard)),
        ),
        child: Stack(children: [
          Center(
              child: Container(
                  height: 150,
                  decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                    BoxShadow(
                      color:
                          GeniusWalletColors.lightGreenPrimary.withOpacity(.5),
                      spreadRadius: 2,
                      blurRadius: 80,
                    )
                  ]))),
          Column(children: [
            Row(children: [
              Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: WalletTypeIcon(walletType: widget.walletType)),
              Flexible(
                  child: Container(
                child: AutoSizeText(
                  overflow: TextOverflow.ellipsis,
                  widget.walletName ?? '',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: GeniusWalletFontSize.medium,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.25,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.left,
                ),
              )),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Flexible(
                  child: Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: AutoSizeText(
                          WalletUtils.getAddressForDisplay(
                              widget.walletAddress ?? ""),
                          maxLines: 1,
                          style: const TextStyle(
                              color: GeniusWalletColors.gray500)))),
              const SizedBox(width: 8),
              Flexible(
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Flexible(
                    child: AutoSizeText(
                  WalletUtils.truncateToDecimals(widget.ovrWalletBalance ?? ""),
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                )),
                const SizedBox(width: 5),
                Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: AutoSizeText(
                      widget.ovrCoinSymbol ?? '',
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2571428716182709,
                        color: GeniusWalletColors.gray500,
                      ),
                    ))
              ])),
            ]),
          ]),
          Positioned(
            left: 20.0,
            right: 20.0,
            bottom: 0,
            height: 120.0,
            child: SizedBox(
                child: Stack(children: [
              Positioned(
                left: widget.constraints.maxWidth * 0.061,
                width: widget.constraints.maxWidth * 0.338,
                top: 13.0,
                height: 12.0,
                child: SizedBox(
                    height: 12.0,
                    width: widget.constraints.maxWidth * 0.33762057877813506,
                    child: AutoSizeText(
                      widget.ovrTimestamp ?? '',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 10.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.25,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.582,
                width: widget.constraints.maxWidth * 0.244,
                top: 13.0,
                height: 14.0,
                child: SizedBox(
                    height: 14.0,
                    width: widget.constraints.maxWidth * 0.24437299035369775,
                    child: AutoSizeText(
                      widget.ovrLastTransactionValue ?? '',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Center(
                    child: SizedBox(
                        child: AutoSizeText(
                  widget.ovrLastTransactionID ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ))),
              ),
            ])),
          ),
          Positioned(
            left: widget.constraints.maxWidth * 0.064,
            width: widget.constraints.maxWidth * 0.871,
            top: widget.constraints.maxHeight * 0.293,
            height: widget.constraints.maxHeight * 0.296,
            child: Container(
                child: widget.ovrTrendLine ??
                    SvgPicture.asset(
                      'assets/images/trendline.svg',
                      package: 'genius_wallet',
                      height: widget.constraints.maxHeight * 0.2962962962962963,
                      width: widget.constraints.maxWidth * 0.8713826366559485,
                      fit: BoxFit.fill,
                    )),
          ),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
