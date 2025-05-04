import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

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
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
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
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox.shrink();
                            },
                          )),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          dappUrl,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 16),
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
        )
      ],
      footer: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
              ),
              child: const Text("Reject", style: TextStyle(color: Colors.grey)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                side: const BorderSide(color: Colors.greenAccent),
              ),
              child:
                  const Text("Approve", style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}
