import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

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
            padding: const EdgeInsets.all(8),
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
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox.shrink();
                        },
                      )),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      dappName,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Flexible(
                child: Text(
                  dappUrl,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        if (dappDescription != null && dappDescription.isNotEmpty) ...[
          Text(
            dappDescription,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
        ],
      ],
      footer: Column(children: [
        Text(
          "Allow $dappName to connect to your wallet?",
          style: const TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                ),
                child: const Text("Deny", style: TextStyle(color: Colors.grey)),
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
                    const Text("Allow", style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        )
      ]),
    );
  }
}
