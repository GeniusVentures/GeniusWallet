import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_api/types/wallet_type.dart';
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
        width: widget.constraints.maxWidth * 1.0,
        height: widget.constraints.maxHeight * 1.0,
        child: Stack(children: [
          Positioned(
            left: 12,
            bottom: 8,
            child: SizedBox(
                width: 120.0,
                child: AutoSizeText(
                  overflow: TextOverflow.ellipsis,
                  widget.walletName ?? "",
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                )),
          ),
          Positioned(
            right: 12.0,
            bottom: 6,
            child: SizedBox(
                width: 170.0,
                child: AutoSizeText(
                  widget.ovrWalletBalance ?? '0.221746',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.4,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                )),
          ),
          Positioned(
            right: 12,
            width: 30.0,
            top: 16.0,
            height: 30.0,
            child: SizedBox(child: widget.ovrCoinIcon ?? const SizedBox()),
          ),
          Positioned(
              left: 12.0,
              top: 18.0,
              child: WalletTypeIcon(walletType: widget.walletType)),
          Positioned(
            left: 48.0,
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
