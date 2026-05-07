import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

/// Brand-styled toggle switch. Use for binary settings (notifications,
/// biometric unlock, network toggles). Prefers a label-on-left layout so the
/// caller doesn't have to wire up a Row themselves.
class GWSwitch extends StatelessWidget {
  const GWSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.description,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final String? description;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final disabled = !enabled || onChanged == null;

    final toggle = Switch.adaptive(
      value: value,
      onChanged: disabled ? null : onChanged,
      activeColor: GeniusWalletColors.brandPrimary,
      activeTrackColor: GeniusWalletColors.brandPrimary.withAlpha(140),
      inactiveThumbColor: GeniusWalletColors.textPrimary,
      inactiveTrackColor: GeniusWalletColors.surfaceMenu,
      trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
        (states) => GeniusWalletColors.borderSubtle,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    if (label == null && description == null) return toggle;

    return InkWell(
      onTap: disabled ? null : () => onChanged!(!value),
      borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: GeniusWalletConsts.space2,
          vertical: GeniusWalletConsts.space2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (label != null)
                    Text(
                      label!,
                      style: GeniusWalletTypography.bodyMd.copyWith(
                        color: disabled
                            ? GeniusWalletColors.textTertiary
                            : GeniusWalletColors.textPrimary,
                      ),
                    ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      style: GeniusWalletTypography.bodySm.copyWith(
                        color: GeniusWalletColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: GeniusWalletConsts.space6),
            toggle,
          ],
        ),
      ),
    );
  }
}
