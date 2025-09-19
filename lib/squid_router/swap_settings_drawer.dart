import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';

class SwapSettingsDrawer {
  static void show(
    BuildContext context, {
    required double initialSlippage,
    required ValueChanged<double> onSlippageChanged,
  }) {
    final TextEditingController slippageController =
        TextEditingController(text: initialSlippage.toString());
    final formKey = GlobalKey<FormState>();

    ResponsiveDrawer.show<void>(
      context: context,
      title: "Swap Settings",
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Explanatory text
                const Text(
                  "Adjust the allowed price difference for swaps. "
                  "Lower values = less risk, but may fail in volatile markets.",
                  style: TextStyle(
                    color: GeniusWalletColors.gray500,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Slippage Tolerance (%)",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Form(
                  key: formKey,
                  child: TextFormField(
                    controller: slippageController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      filled: true,
                      fillColor: GeniusWalletColors.deepBlue,
                      hintText: "0.1 - 5.0",
                      hintStyle: const TextStyle(color: Colors.white38),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      errorStyle: const TextStyle(
                          color: Colors.redAccent, fontSize: 13),
                      isDense: true,
                    ),
                    validator: (value) {
                      final parsed = double.tryParse(value ?? '');
                      if (parsed == null) return "Enter a valid number";
                      if (parsed < 0.1 || parsed > 5.0) {
                        return "Must be between 0.1% and 5%";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
      footer: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if ((formKey.currentState?.validate() ?? false)) {
                final parsed = double.parse(slippageController.text);
                onSlippageChanged(parsed);
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: GeniusWalletGradient.greenBlueGreenGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                height: 48,
                alignment: Alignment.center,
                child: const Text(
                  "Apply",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
