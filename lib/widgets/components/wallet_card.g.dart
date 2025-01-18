import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';

class WalletCard extends StatefulWidget {

  final String? walletName;
  final String? walletIcon;
  final VoidCallback? onTap;

  const WalletCard({
    Key? key,
    this.walletName = "Ethereum",
    this.walletIcon,
    this.onTap,
  }) : super(key: key);

  @override
  _WalletCardState createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> {
  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Container(
      decoration: BoxDecoration(
        color: GeniusWalletColors.deepBlueCardColor,
        borderRadius:
            BorderRadius.circular(GeniusWalletConsts.borderRadiusButton),
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(GeniusWalletConsts.borderRadiusButton),
          ),
          backgroundColor: GeniusWalletColors.deepBlueCardColor,
        ),
        onPressed: widget.onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon and Wallet Name
            Flexible(
                child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Wallet Icon
                if (widget.walletIcon != null)
                  Image.asset(
                    widget.walletIcon!,
                    package: 'genius_wallet',
                    height: 30.0 * textScaleFactor,
                    width: 30.0 * textScaleFactor,
                    fit: BoxFit.contain,
                  )
                else
                  CircleAvatar(
                    radius: 15.0 * textScaleFactor,
                    backgroundColor: Colors.grey[400],
                    child: const Icon(Icons.account_balance_wallet, size: 16),
                  ),
                const SizedBox(width: 12),
                // Wallet Name
                Flexible(
                    child: AutoSizeText(
                  widget.walletName ?? '',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14.0 * textScaleFactor,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
              ],
            )),
            // Arrow Icon
            SvgPicture.asset(
              'assets/images/whitearrowright.svg',
              package: 'genius_wallet',
              height: 14.0 * textScaleFactor,
              width: 12.0 * textScaleFactor,
              fit: BoxFit.none,
            ),
          ],
        ),
      ),
    );
  }
}
