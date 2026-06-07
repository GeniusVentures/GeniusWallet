import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

class SwapDrawerContent extends StatelessWidget {
  final String fromAmount;
  final String toAmount;
  final String fromIconUrl;
  final String toIconUrl;
  final String fromSymbol;
  final String toSymbol;
  final String chain;
  final bool isSuccess;

  const SwapDrawerContent({
    super.key,
    required this.fromAmount,
    required this.toAmount,
    required this.fromIconUrl,
    required this.toIconUrl,
    required this.fromSymbol,
    required this.toSymbol,
    required this.chain,
    this.isSuccess = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 90,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: const Offset(-20, 0),
                child: ClipOval(
                  child: Image.network(
                    fromIconUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(10, 20),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: GeniusWalletColors.deepBlueCardColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: GeniusWalletColors.deepBlueTertiary, width: 1),
                    image: DecorationImage(
                      image: NetworkImage(toIconUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "$fromAmount $fromSymbol → $toAmount $toSymbol",
          style: GeniusWalletTypography.titleMd.copyWith(
            color: isSuccess
                ? GeniusWalletColors.textPrimary
                : GeniusWalletColors.statusError,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Swap on $chain",
          style: GeniusWalletTypography.bodyMd
              .copyWith(color: GeniusWalletColors.textSecondary),
        ),
        if (!isSuccess)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              "Your swap could not be completed.",
              style: TextStyle(color: GeniusWalletColors.statusError),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
