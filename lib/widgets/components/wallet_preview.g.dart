import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/widgets/components/wallet_type_icon.dart';
import 'package:genius_wallet/app/utils/wallet_utils.dart';

class WalletPreview extends StatefulWidget {
  final WalletType? walletType;
  final String? ovrWalletBalance;
  final String? ovrCoinSymbol;
  final String? walletName;
  final String? walletAddress;
  const WalletPreview(
      {Key? key,
      this.walletType,
      this.ovrWalletBalance,
      this.ovrCoinSymbol,
      this.walletAddress,
      this.walletName = ""})
      : super(key: key);
  @override
  WalletPreviewState createState() => WalletPreviewState();
}

class WalletPreviewState extends State<WalletPreview> {
  WalletPreviewState();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
        decoration: const BoxDecoration(
            color: GeniusWalletColors.deepBlueCardColor,
            borderRadius: BorderRadius.all(
                Radius.circular(GeniusWalletConsts.borderRadiusCard))),
        child: Row(children: [
          Image.asset(
              "assets/images/crypto/${widget.ovrCoinSymbol?.toLowerCase()}.png",
              height: 48,
              width: 48, errorBuilder: (context, error, stackTrace) {
            return const SizedBox(height: 48, width: 48);
          }),
          const SizedBox(width: 12),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(widget.walletName ?? ""),
                const SizedBox(height: 4),
                AutoSizeText(
                    style: const TextStyle(color: GeniusWalletColors.gray500),
                    WalletUtils.getAddressForDisplay(
                        widget.walletAddress ?? "")),
              ]),
          const Expanded(child: SizedBox()),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                WalletTypeIcon(walletType: widget.walletType),
                const SizedBox(height: 4),
                Row(children: [
                  AutoSizeText(
                      style: const TextStyle(color: GeniusWalletColors.gray500),
                      widget.ovrWalletBalance ?? ""),
                  const SizedBox(width: 8),
                  AutoSizeText(
                      style: const TextStyle(color: GeniusWalletColors.gray500),
                      widget.ovrCoinSymbol ?? "")
                ])
              ])
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
