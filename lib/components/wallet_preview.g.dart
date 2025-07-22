import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/components/animation/checkmark_animation.dart';
import 'package:genius_wallet/components/wallet_type_icon.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';

class WalletPreview extends StatefulWidget {
  final WalletType? walletType;
  final Widget? walletBalance;
  final String? ovrCoinSymbol;
  final String? walletName;
  final String? walletAddress;
  final bool? isConnected;
  final bool? isShowSymbol;

  const WalletPreview(
      {Key? key,
      this.isConnected,
      this.walletType,
      this.walletBalance,
      this.ovrCoinSymbol,
      this.walletAddress,
      this.walletName = "",
      this.isShowSymbol})
      : super(key: key);

  @override
  WalletPreviewState createState() => WalletPreviewState();
}

class WalletPreviewState extends State<WalletPreview> {
  WalletPreviewState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: GeniusWalletColors.deepBlueCardColor,
        borderRadius: BorderRadius.all(
          Radius.circular(GeniusWalletConsts.borderRadiusCard),
        ),
      ),
      child: Row(children: [
        // Icon for the crypto asset
        Image.asset(
          "assets/images/crypto/${widget.ovrCoinSymbol?.toLowerCase()}.png",
          height: 36,
          width: 36,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox(height: 40, width: 40);
          },
        ),
        const SizedBox(width: 10),
        // Wallet Information
        Flexible(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              Flexible(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: AutoSizeText(
                            widget.walletName ?? "",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.isConnected ?? false)
                          const SizedBox(width: 8),
                        if (widget.isConnected ?? false)
                          const Tooltip(
                            message:
                                'This wallet is connected to the SGNUS network',
                            textStyle:
                                TextStyle(fontSize: 16, color: Colors.black),
                            child: CheckmarkAnimation(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    AutoSizeText(
                      WalletUtils.getAddressForDisplay(
                          widget.walletAddress ?? ""),
                      style: const TextStyle(color: GeniusWalletColors.gray500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Wallet Type and Balance
              Flexible(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    WalletTypeIcon(walletType: widget.walletType),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        widget.walletBalance ??
                            const SizedBox
                                .shrink(), // Fallback if no balance widget is provided
                        if (widget.isShowSymbol ?? true)
                          Flexible(
                            child: AutoSizeText(
                              (" ${widget.ovrCoinSymbol}"),
                              maxLines: 1,
                              style: const TextStyle(
                                color: GeniusWalletColors.gray500,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ]))
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
