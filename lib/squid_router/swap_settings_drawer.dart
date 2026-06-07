import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

class SwapSettingsDrawer {
  static void show(
    BuildContext context, {
    required double initialSlippage,
    required ValueChanged<double> onSlippageChanged,
  }) {
    final TextEditingController slippageController =
        TextEditingController(text: initialSlippage.toString());

    ResponsiveDrawer.show<void>(
      context: context,
      title: "Swap Settings",
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Slippage Tolerance (%)",
                  style: GeniusWalletTypography.titleMd,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: slippageController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: "Enter slippage",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ],
      footer: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            final parsed = double.tryParse(slippageController.text);
            if (parsed != null) {
              onSlippageChanged(parsed);
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: GeniusWalletGradient.greenBlueGreenGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              height: 48,
              alignment: Alignment.center,
              child: const Text(
                "Apply",
                style: TextStyle(
                  color: GeniusWalletColors.textOnBrand,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
