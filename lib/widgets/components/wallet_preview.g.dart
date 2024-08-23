import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/widgets/components/wallet_type_icon.dart';

class WalletPreview extends StatefulWidget {
  final BoxConstraints constraints;
  final WalletType? walletType;
  final String? ovrWalletBalance;
  final Widget? ovrCoinIcon;
  final String? ovrCoinSymbol;
  final String? walletName;
  const WalletPreview(this.constraints,
      {Key? key,
      this.walletType,
      this.ovrWalletBalance,
      this.ovrCoinIcon,
      this.ovrCoinSymbol,
      this.walletName = ""})
      : super(key: key);
  @override
  _WalletPreview createState() => _WalletPreview();
}

class _WalletPreview extends State<WalletPreview> {
  _WalletPreview();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Stack(children: [
      Positioned(
        left: 0,
        width: widget.constraints.maxWidth * 1.0,
        top: 0,
        height: widget.constraints.maxHeight * 1.0,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: Container(
              height: widget.constraints.maxHeight * 1.0,
              width: widget.constraints.maxWidth * 1.0,
              decoration: const BoxDecoration(
                color: GeniusWalletColors.deepBlueCardColor,
                borderRadius: BorderRadius.all(
                    Radius.circular(GeniusWalletConsts.borderRadiusCard)),
              ),
            ),
          ),
          Positioned(
            left: 12.0,
            bottom: 13.0,
            height: 19.0,
            child: SizedBox(
                height: 19.0,
                width: 100.0,
                child: AutoSizeText(
                  widget.walletName ?? "",
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16.0,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.0,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                )),
          ),
          Positioned(
            right: 11.0,
            width: 102.0,
            bottom: 12.0,
            height: 28.0,
            child: SizedBox(
                height: 28.0,
                width: 102.0,
                child: AutoSizeText(
                  widget.ovrWalletBalance ?? '0.221746',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 24.0,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.30000001192092896,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                )),
          ),
          Positioned(
            right: 16,
            width: 35.0,
            top: 12.0,
            height: 35.0,
            child: SizedBox(
                child: Stack(children: [
              Positioned(
                right: 0,
                width: 35.0,
                top: 0,
                height: 35.0,
                child: Container(
                  height: 35.0,
                  width: 35.0,
                  decoration: const BoxDecoration(
                    color: GeniusWalletColors.currencyBackground,
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
              Positioned(
                  left: 8.922,
                  width: 16.484,
                  top: 7.656,
                  height: 21.82,
                  child: widget.ovrCoinIcon ?? const SizedBox()),
            ])),
          ),
          Positioned(
              left: 16.0,
              top: 18.0,
              child: WalletTypeIcon(walletType: widget.walletType)),
          Positioned(
            left: 60.0,
            width: 49.0,
            top: 21.0,
            height: 14.0,
            child: SizedBox(
                height: 14.0,
                width: 49.0,
                child: AutoSizeText(
                  widget.ovrCoinSymbol ?? 'BTC',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.25714290142059326,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.left,
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
