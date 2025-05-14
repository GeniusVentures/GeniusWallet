import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';

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
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Slippage Tolerance (%)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
      footer: OutlinedButton(
        onPressed: () {
          final parsed = double.tryParse(slippageController.text);
          if (parsed != null) {
            onSlippageChanged(parsed);
            Navigator.of(context).pop();
          }
        },
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: const BorderSide(color: Colors.greenAccent),
          minimumSize: const Size.fromHeight(48),
        ),
        child: const Text(
          "Apply",
          style: TextStyle(color: Colors.greenAccent),
        ),
      ),
    );
  }
}
