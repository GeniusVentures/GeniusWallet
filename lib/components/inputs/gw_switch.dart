import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

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
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this const-instanced widget to rebuild on a live appearance toggle.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final disabled = !enabled || onChanged == null;

    final toggle = Switch.adaptive(
      value: value,
      onChanged: disabled ? null : onChanged,
      // Stateful resolvers, not the legacy active*/inactive* shorthands:
      // Flutter's Switch resolves those without consulting
      // WidgetState.disabled, so a disabled switch used to paint exactly
      // like an off one. The disabled branch must come first so it wins
      // over the selected/unselected branches below.
      thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return gw.textSecondary;
        }
        if (states.contains(WidgetState.selected)) {
          return context.gw.brandPrimaryStrong;
        }
        return gw.textPrimary;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return gw.surfaceMenu;
        }
        if (states.contains(WidgetState.selected)) {
          return context.gw.brandPrimaryStrong.withAlpha(140);
        }
        return gw.surfaceMenu;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return gw.borderControl;
        }
        return gw.borderSubtle;
      }),
      // Keep Flutter's padded 48px min tap target (was shrinkWrap → ~30-40px).
    );

    if (label == null && description == null) {
      return toggle;
    }

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
                        color: disabled ? gw.textSecondary : gw.textPrimary,
                      ),
                    ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      style: GeniusWalletTypography.bodySm.copyWith(
                        color: gw.textSecondary,
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
