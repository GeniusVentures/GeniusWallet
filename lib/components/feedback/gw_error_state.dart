import 'package:flutter/material.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

class GWErrorState extends StatelessWidget {
  const GWErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
  });

  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final String retryLabel;

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
                color: GeniusWalletColors.statusError.withAlpha(31),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 32,
                color: GeniusWalletColors.statusError,
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
            if (onRetry != null) ...[
              const SizedBox(height: GeniusWalletConsts.space8),
              GWButton(
                label: retryLabel,
                onPressed: onRetry,
                variant: GWButtonVariant.primary,
                leading: const Icon(Icons.refresh),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class GWErrorBanner extends StatelessWidget {
  const GWErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
  });

  final String message;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space6,
        vertical: GeniusWalletConsts.space4,
      ),
      decoration: BoxDecoration(
        color: GeniusWalletColors.statusError.withAlpha(31),
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
        border: Border.all(
          color: GeniusWalletColors.statusError.withAlpha(100),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            size: 18,
            color: GeniusWalletColors.statusError,
          ),
          const SizedBox(width: GeniusWalletConsts.space4),
          Expanded(
            child: Text(
              message,
              style: GeniusWalletTypography.bodySm.copyWith(
                color: GeniusWalletColors.statusError,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              tooltip: 'Close',
              icon: const Icon(
                Icons.close,
                size: 18,
                color: GeniusWalletColors.statusError,
              ),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
            ),
        ],
      ),
    );
  }
}
