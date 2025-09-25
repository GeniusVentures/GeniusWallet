import 'package:flutter/material.dart';
import 'package:genius_wallet/test/dev_tools_state.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';

class DevicePreviewExtras extends StatelessWidget {
  const DevicePreviewExtras({super.key});

  @override
  Widget build(BuildContext context) {
    final showDevTools =
        DevToolsState().showDevTools; // 👈 Access singleton state

    return SliverToBoxAdapter(
      child: ValueListenableBuilder<bool>(
        valueListenable: showDevTools,
        builder: (context, isVisible, _) {
          return Container(
            padding:
                const EdgeInsets.only(left: 40, right: 12, top: 12, bottom: 12),
            decoration: const BoxDecoration(
              color: GeniusWalletColors.deepBlueTertiary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Image.asset(
                        'assets/images/geniusappbarlogo.png',
                        height: 30,
                        package: 'genius_wallet',
                      ),
                    ),
                    const Text('Dev Tools',
                        style: TextStyle(color: Colors.white)),
                    const Spacer(),
                    Switch(
                      value: isVisible,
                      onChanged: (value) => showDevTools.value = value,
                      activeColor: Colors.greenAccent,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
