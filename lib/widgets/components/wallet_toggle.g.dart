import 'package:flutter/material.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/wallet_type_icon.dart';

class WalletToggle extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrWalletName;
  final Widget? ovrArrowToggle;
  final Widget? ovrShape;
  final String? ovrCoinName;
  final WalletType? walletType;
  const WalletToggle(this.constraints,
      {Key? key,
      this.ovrWalletName,
      this.ovrArrowToggle,
      this.ovrShape,
      this.ovrCoinName,
      this.walletType})
      : super(key: key);
  @override
  _WalletToggle createState() => _WalletToggle();
}

class _WalletToggle extends State<WalletToggle> {
  _WalletToggle();

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
            WalletTypeIcon(walletType: widget.walletType),
            const SizedBox(
              width: 12,
            ),
            AutoSizeText(
              widget.ovrWalletName ?? 'My Bitcoin Wallet',
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.32307693362236023,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )
          ]),
        ]);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
