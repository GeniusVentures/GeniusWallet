import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/web/web_utils.dart';
import 'package:go_router/go_router.dart';

class SwapResultDrawer {
  static Future<void> show({
    required BuildContext context,
    required bool isSuccess,
    required String txHash,
    required String coinSymbol,
  }) async {
    final message = isSuccess ? "Swap Success" : "Swap Failed";
    final icon = isSuccess ? Icons.check_circle : Icons.error;
    final iconColor = isSuccess ? Colors.greenAccent : Colors.redAccent;
    final explorerUrl =
        (txHash.isNotEmpty) ? getExplorerUrl(coinSymbol, txHash) : '';

    await ResponsiveDrawer.show(
      context: context,
      title: message,
      children: [
        const SizedBox(height: 24),
        Icon(icon, size: 64, color: iconColor),
        const SizedBox(height: 16),
        Text(
          message,
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: iconColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (txHash.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GeniusWalletColors.deepBlueMenu,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Transaction Hash:",
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 4),
                SelectableText(txHash,
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
      ],
      footer: Column(
        children: [
          ElevatedButton(
            onPressed: () => context.push("/transactions"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text(
              "Go to Transactions",
              style: TextStyle(color: GeniusWalletColors.deepBlueTertiary),
            ),
          ),
          const SizedBox(height: 12),
          if (explorerUrl.isNotEmpty)
            OutlinedButton(
              onPressed: () => launchWebSite(context, explorerUrl),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                side: const BorderSide(color: Colors.greenAccent),
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text("View on Explorer",
                  style: TextStyle(color: Colors.greenAccent)),
            ),
        ],
      ),
    );
  }
}
