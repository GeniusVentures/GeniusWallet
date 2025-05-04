import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Left-aligned Close Icon
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white12),
            const SizedBox(height: 4),
            // Scrollable content
            Expanded(
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: ListView.builder(
                    itemCount: children.length,
                    itemBuilder: (context, index) => children[index],
                  )),
            ),

            // Footer
            if (footer != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: footer!,
              ),
          ],
        ),
      ),
    );
  }
}
