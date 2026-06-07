import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

class ApproveTransactionDrawer {
  static Future<bool?> show({
    required BuildContext context,
    required Widget content,
    required String dappName,
    required String dappUrl,
    String? iconUrl,
  }) async {
    return ResponsiveDrawer.show<bool>(
      context: context,
      title: "Transaction Request",
      children: [
        Padding(
          padding: const EdgeInsets.all(GeniusWalletConsts.space8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(GeniusWalletConsts.space4),
                  decoration: BoxDecoration(
                    border: Border.all(color: GeniusWalletColors.textSecondary),
                    borderRadius: BorderRadius.circular(
                        GeniusWalletConsts.borderRadiusButton),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Image.network(
                            iconUrl ?? "",
                            height: 24,
                            width: 24,
                            fit: BoxFit.cover,
                            excludeFromSemantics: true,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox.shrink();
                            },
                          )),
                      const SizedBox(width: GeniusWalletConsts.space6),
                      Flexible(
                        child: Text(
                          dappUrl,
                          style: GeniusWalletTypography.bodyLg.copyWith(
                              color: GeniusWalletColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: GeniusWalletConsts.space6),
              Flexible(fit: FlexFit.loose, child: content),
            ],
          ),
        )
      ],
      footer: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: GeniusWalletColors.textSecondary),
              ),
              child: const Text("Reject",
                  style: TextStyle(color: GeniusWalletColors.textSecondary)),
            ),
          ),
          const SizedBox(width: GeniusWalletConsts.space6),
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: OutlinedButton.styleFrom(
                backgroundColor: GeniusWalletColors.brandGreen,
                side: const BorderSide(color: GeniusWalletColors.brandGreen),
              ),
              child: const Text("Approve",
                  style: TextStyle(color: GeniusWalletColors.textOnBrand)),
            ),
          ),
        ],
      ),
    );
  }
}
