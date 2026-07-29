import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/web/web_utils.dart';
import 'package:go_router/go_router.dart';

class SwapResultDrawer {
  static Future<void> show({
    required BuildContext context,
    required bool isSuccess,
    required String txHash,
    required String coinSymbol,
  }) async {
    final gw = context.gw;
    final message = isSuccess ? "Swap Success" : "Swap Failed";
    final icon = isSuccess ? Icons.check_circle : Icons.error;
    final iconColor = isSuccess ? gw.statusSuccess : gw.statusError;
    final explorerUrl = (txHash.isNotEmpty)
        ? getExplorerUrl(coinSymbol, txHash)
        : '';

    await ResponsiveDrawer.show(
      context: context,
      title: message,
      child: ListView(
        children: [
          const SizedBox(height: 24),
          Icon(icon, size: 64, color: iconColor),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (txHash.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: gw.deepBlueMenu,
                borderRadius: BorderRadius.circular(12),
              ),
              // deepBlueMenu is a FIXED dark-navy fill (does not flip with
              // appearance -- see the token map), so the text on it must
              // stay fixed white too: a mode-following gw.textPrimary would
              // go ink-on-dark-navy in light mode. Documented fixed
              // exception, matching this plan's own "text on a fixed dark
              // scrim" guidance.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Transaction Hash:",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    txHash,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
      footer: Column(
        children: [
          ElevatedButton(
            onPressed: () => context.push("/transactions"),
            style: ElevatedButton.styleFrom(
              backgroundColor: gw.statusSuccess,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(
              "Go to Transactions",
              style: TextStyle(color: gw.deepBlueTertiary),
            ),
          ),
          const SizedBox(height: 12),
          if (explorerUrl.isNotEmpty)
            OutlinedButton(
              onPressed: () => launchWebSite(context, explorerUrl),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: BorderSide(color: gw.statusSuccess),
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(
                "View on Explorer",
                style: TextStyle(color: gw.statusSuccess),
              ),
            ),
        ],
      ),
    );
  }
}
