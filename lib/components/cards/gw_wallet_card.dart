import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// Replacement for the Parabeac-generated WalletCard widget.
/// Visual-only surface with icon + name + optional trailing arrow.
class GWWalletCard extends StatelessWidget {
  const GWWalletCard({
    super.key,
    this.walletName = 'Ethereum',
    this.walletIcon,
    this.onTap,
    this.showArrow = true,
  });

  final String? walletName;
  final String? walletIcon;
  final VoidCallback? onTap;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this const-instanced widget to rebuild on a live appearance toggle.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return GWCard(
      onTap: onTap,
      radius: GeniusWalletConsts.radiusPill,
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space12,
        vertical: GeniusWalletConsts.space10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (walletIcon != null)
                  Image.asset(
                    walletIcon!,
                    package: 'genius_wallet',
                    semanticLabel: walletName,
                    height: 30,
                    width: 30,
                    fit: BoxFit.contain,
                  )
                else
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: gw.surfaceMenu,
                    child: Icon(
                      Icons.account_balance_wallet,
                      size: 16,
                      color: gw.textPrimary,
                    ),
                  ),
                const SizedBox(width: GeniusWalletConsts.space6),
                Flexible(
                  child: AutoSizeText(
                    walletName ?? '',
                    style: GeniusWalletTypography.bodyMd
                        .copyWith(color: gw.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (showArrow)
            SvgPicture.asset(
              'assets/images/whitearrowright.svg',
              package: 'genius_wallet',
              height: 14,
              width: 12,
              fit: BoxFit.none,
            ),
        ],
      ),
    );
  }
}
