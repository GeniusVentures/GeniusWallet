import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

class BottomDrawer extends StatelessWidget {
  final List<Widget> children;
  final String? title;
  final Widget? footer;

  const BottomDrawer({
    super.key,
    required this.children,
    this.title,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GeniusWalletColors.deepBlueTertiary,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: GeniusWalletConsts.space8,
                  vertical: GeniusWalletConsts.space6),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Centered Title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30), // Leaves space for X
                    child: Text(
                      title ?? '',
                      textAlign: TextAlign.center,
                      style: GeniusWalletTypography.titleMd.copyWith(
                        color: GeniusWalletColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Left-aligned Close Icon
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip: 'Close',
                      icon: const Icon(Icons.close, color: GeniusWalletColors.textPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: GeniusWalletColors.textPrimary12),
            const SizedBox(height: GeniusWalletConsts.space2),
            // Scrollable content
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: GeniusWalletConsts.space8,
                      vertical: GeniusWalletConsts.space6),
                  child: ListView.builder(
                    itemCount: children.length,
                    itemBuilder: (context, index) => children[index],
                  )),
            ),

            // Footer
            if (footer != null)
              Padding(
                padding: const EdgeInsets.all(GeniusWalletConsts.space8),
                child: footer!,
              ),
          ],
        ),
      ),
    );
  }
}
