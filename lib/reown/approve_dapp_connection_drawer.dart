import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

class ApproveDappConnectionDrawer {
  static Future<bool?> show({
    required BuildContext context,
    required String dappName,
    required String dappUrl,
    String? dappDescription,
    String? iconUrl,
  }) {
    final gw = context.gw;
    return ResponsiveDrawer.show<bool>(
      context: context,
      title: "Connection Request",
      child: ListView(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  GeniusWalletConsts.borderRadiusButton,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          dappName,
                          style: TextStyle(color: gw.textPrimary, fontSize: 20),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Flexible(
                    child: Text(
                      dappUrl,
                      style: TextStyle(color: gw.textSecondary, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (dappDescription != null && dappDescription.isNotEmpty) ...[
            Text(
              dappDescription,
              style: TextStyle(color: gw.textPrimary70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
      footer: Column(
        children: [
          Text(
            "Allow $dappName to connect to your wallet?",
            style: TextStyle(color: gw.textPrimary, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: gw.borderStrong),
                  ),
                  child: Text(
                    "Deny",
                    style: TextStyle(color: gw.textSecondary),
                  ),
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
                  // Fixed black regardless of appearance: statusSuccess is
                  // the fill here (not a surface), and black is the only
                  // foreground that clears 4.5:1 against BOTH its dark-mode
                  // and light-mode values (measured in 23-03-CONTRAST.md) --
                  // matches this file's planner-discipline-allowed exception.
                  child: const Text(
                    "Allow",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
