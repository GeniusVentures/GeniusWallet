import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

class CoinCardRow extends StatelessWidget {
  final String iconPath;
  final String name;
  final String symbol;
  final double balance;
  final VoidCallback? onTap;

  const CoinCardRow({
    Key? key,
    required this.iconPath,
    required this.name,
    required this.balance,
    required this.symbol,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: GeniusWalletColors.deepBlueCardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  iconPath,
                  height: 48,
                  width: 48,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(height: 48, width: 48);
                  },
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 320,
                      child: AutoSizeText(
                        name,
                        maxLines: 1,
                        minFontSize: 12,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        AutoSizeText(
                          balance == 0 ? '0' : balance.toStringAsFixed(2),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: GeniusWalletColors.gray500),
                        ),
                        const SizedBox(width: 8),
                        AutoSizeText(
                          symbol,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: GeniusWalletColors.gray500),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
