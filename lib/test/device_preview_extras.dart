import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';

class DevicePreviewExtras extends StatefulWidget {
  const DevicePreviewExtras({super.key});

  @override
  State<DevicePreviewExtras> createState() => _DevicePreviewExtrasState();
}

class _DevicePreviewExtrasState extends State<DevicePreviewExtras> {
  bool _showDevTools = false;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(left: 40, right: 12, top: 12, bottom: 12),
        decoration: BoxDecoration(
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
                  value: _showDevTools,
                  onChanged: (value) =>
                      setState(() => _showDevTools = value),
                  activeThumbColor: Colors.greenAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
