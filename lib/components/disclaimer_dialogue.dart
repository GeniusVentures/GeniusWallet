import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

Future<bool> showDisclaimerDialog(
  BuildContext context, {
  String? title,
  String? message,
  String? confirmText,
  String? checkboxText,
  Color? activeColor,
  Color? textColor,
}) async {
  bool isAccepted = false;

  final resolvedTextColor = textColor ?? GeniusWalletColors.textPrimary;
  final resolvedActiveColor = activeColor ?? GeniusWalletColors.brandPrimary;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            title ?? "Disclaimer",
            style: GeniusWalletTypography.headlineMd,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message ??
                    "You are now leaving GeniusWallet for Banxa (https://banxa.com). "
                        "Services related to card payments are provided by Banxa, "
                        "a separate third-party platform. By proceeding, you acknowledge "
                        "that you have read and agreed to Banxa's Terms of Use and Privacy Policy.",
                style: GeniusWalletTypography.bodyMd
                    .copyWith(color: resolvedTextColor),
              ),
              const SizedBox(height: GeniusWalletConsts.space6),
              Row(
                children: [
                  Checkbox(
                    value: isAccepted,
                    onChanged: (value) {
                      setState(() {
                        isAccepted = value ?? false;
                      });
                    },
                    activeColor: resolvedActiveColor,
                    checkColor: GeniusWalletColors.textPrimary,
                    side: BorderSide(
                        color: GeniusWalletColors.textPrimary, width: 1.5),
                  ),
                  Expanded(
                    child: Text(
                      checkboxText ?? "I have read and agree to the disclaimer",
                      style: GeniusWalletTypography.bodyMd
                          .copyWith(color: resolvedTextColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(isAccepted),
              child: Text(confirmText ?? "Confirm"),
            ),
          ],
        ),
      );
    },
  );

  return isAccepted;
}
