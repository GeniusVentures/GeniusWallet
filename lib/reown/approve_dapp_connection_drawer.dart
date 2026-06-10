import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

class ApproveDappConnectionDrawer {
  static Future<bool?> show({
    required BuildContext context,
    required String dappName,
    required String dappUrl,
    String? dappDescription,
    String? iconUrl,
  }) {
    return ResponsiveDrawer.show<bool>(
      context: context,
      title: "Connection Request",
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(GeniusWalletConsts.space4),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(GeniusWalletConsts.borderRadiusButton),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Image.network(
                        iconUrl ?? "",
                        height: 28,
                        width: 28,
                        fit: BoxFit.cover,
                        semanticLabel: dappName,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox.shrink();
                        },
                      )),
                  const SizedBox(width: GeniusWalletConsts.space6),
                  Flexible(
                    child: Text(
                      dappName,
                      style: TextStyle(
                          color: GeniusWalletColors.textPrimary, fontSize: 20),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Flexible(
                child: Text(
                  dappUrl,
                  style: GeniusWalletTypography.bodyMd
                      .copyWith(color: GeniusWalletColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: GeniusWalletConsts.space8),
        if (dappDescription != null && dappDescription.isNotEmpty) ...[
          Text(
            dappDescription,
            style: GeniusWalletTypography.bodyMd
                .copyWith(color: GeniusWalletColors.textPrimary70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: GeniusWalletConsts.space6),
        ],
      ],
      footer: Column(children: [
        Text(
          "Allow $dappName to connect to your wallet?",
          style: GeniusWalletTypography.bodyLg,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: GeniusWalletConsts.space10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  side:
                      const BorderSide(color: GeniusWalletColors.textSecondary),
                ),
                child: const Text("Deny",
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
                child: const Text("Allow",
                    style: TextStyle(color: GeniusWalletColors.textOnBrand)),
              ),
            ),
          ],
        )
      ]),
    );
  }
}
