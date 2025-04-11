import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

class BottomDrawer extends StatelessWidget {
  final List<Widget> children;
  final String? title;

  const BottomDrawer({
    super.key,
    required this.children,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GeniusWalletColors.deepBlueTertiary,
      child: Column(
        children: [
          _buildHeader(context),
          const Divider(height: 1, color: Colors.white12),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: children.length,
              itemBuilder: (context, index) => children[index],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: GeniusWalletColors.deepBlueCardColor,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          if (title != null)
            Center(
              child: Text(
                title!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
