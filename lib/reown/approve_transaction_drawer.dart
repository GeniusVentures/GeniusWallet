import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

class ApproveTransactionDrawer {
  static Future<bool?> show({
    required BuildContext context,
    required Widget content,
    required String dappName,
    required String dappUrl,
    String? iconUrl,
  }) async {
    final gw = context.gw;
    return ResponsiveDrawer.show<bool>(
      context: context,
      title: "Transaction Request",
      child: ListView(
        children: [
          // Was EdgeInsets.all(16): the shell now supplies the body inset
          // (kDrawerBodyPadding), so keeping this would render 36 on the sides.
          Padding(
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: gw.borderStrong),
                      borderRadius: BorderRadius.circular(
                        GeniusWalletConsts.borderRadiusButton,
                      ),
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
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            dappUrl,
                            style: TextStyle(
                              color: gw.textSecondary,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(fit: FlexFit.loose, child: content),
              ],
            ),
          ),
        ],
      ),
      footer: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: gw.borderStrong),
              ),
              child: Text("Reject", style: TextStyle(color: gw.textSecondary)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: OutlinedButton.styleFrom(
                backgroundColor: gw.statusSuccess,
                side: BorderSide(color: gw.statusSuccess),
              ),
              // Fixed black regardless of appearance -- see
              // approve_dapp_connection_drawer.dart's identical Allow
              // button for the measured ratios (23-03-CONTRAST.md).
              child: const Text(
                "Approve",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
