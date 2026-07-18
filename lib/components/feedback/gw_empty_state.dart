import 'package:flutter/material.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

class GWEmptyState extends StatelessWidget {
  const GWEmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this const-instanced widget to rebuild on a live appearance toggle.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GeniusWalletConsts.space12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: GWDecorations.surfaceSheen,
                shape: BoxShape.circle,
                border: Border.all(color: gw.borderSubtle),
              ),
              child: Icon(
                icon,
                size: 32,
                color: gw.textSecondary,
              ),
            ),
            const SizedBox(height: GeniusWalletConsts.space8),
            Text(
              title,
              style: GeniusWalletTypography.titleLg,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: GeniusWalletConsts.space4),
              Text(
                message!,
                style: GeniusWalletTypography.bodyMd.copyWith(
                  color: gw.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: GeniusWalletConsts.space8),
              GWButton(
                label: actionLabel,
                onPressed: onAction,
                variant: GWButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
