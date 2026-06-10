import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

class GWTokenRow extends StatelessWidget {
  const GWTokenRow({
    super.key,
    required this.symbol,
    required this.name,
    this.iconAsset,
    this.iconWidget,
    this.balance,
    this.subBalance,
    this.trailing,
    this.onTap,
  });

  final String symbol;
  final String name;
  final String? iconAsset;
  final Widget? iconWidget;
  final String? balance;
  final String? subBalance;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: GeniusWalletConsts.space6,
            vertical: GeniusWalletConsts.space4,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: iconWidget ??
                    (iconAsset != null
                        ? Image.asset(
                            iconAsset!,
                            semanticLabel: symbol,
                            errorBuilder: (_, __, ___) => const _FallbackDot(),
                          )
                        : const _FallbackDot()),
              ),
              const SizedBox(width: GeniusWalletConsts.space6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      symbol,
                      style: GeniusWalletTypography.titleMd,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      name,
                      style: GeniusWalletTypography.bodySm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (balance != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      balance!,
                      style: GeniusWalletTypography.numericBody,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subBalance != null)
                      Text(
                        subBalance!,
                        style: GeniusWalletTypography.bodySm,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FallbackDot extends StatelessWidget {
  const _FallbackDot();

  @override
  Widget build(BuildContext context) => CircleAvatar(
        radius: 20,
        backgroundColor: GeniusWalletColors.surfaceMenu,
        child: const Icon(
          Icons.token,
          size: 18,
          color: GeniusWalletColors.textSecondary,
        ),
      );
}
