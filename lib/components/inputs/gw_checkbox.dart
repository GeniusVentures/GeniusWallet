import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// Brand-styled checkbox with optional label / description. Styling follows
/// the GNUS palette (cyan brand fill, white check, subtle outline when off).
///
/// For a tri-state checkbox pass [tristate]: true and use a nullable [value].
class GWCheckbox extends StatelessWidget {
  const GWCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.description,
    this.tristate = false,
    this.enabled = true,
  });

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final String? description;
  final bool tristate;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this const-instanced widget to rebuild on a live appearance toggle.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final disabled = !enabled || onChanged == null;

    // A natural Checkbox keeps Flutter's padded ~48px tap target (touch floor);
    // the visible box stays ~18px (was capped to 24 + shrinkWrap → 24px tap).
    final box = Checkbox(
        value: value,
        tristate: tristate,
        onChanged: disabled ? null : onChanged,
        side: BorderSide(
          color: disabled ? gw.borderSubtle : GeniusWalletColors.brandPrimary,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(GeniusWalletConsts.radiusXs),
        ),
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.disabled)) {
            return gw.borderSubtle;
          }
          if (states.contains(WidgetState.selected)) {
            return GeniusWalletColors.brandPrimary;
          }
          return Colors.transparent;
        }),
        checkColor: gw.textPrimary,
      );

    if (label == null && description == null) return box;

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Text(
            label!,
            style: GeniusWalletTypography.bodyMd.copyWith(
              color: disabled ? GeniusWalletColors.textTertiary : gw.textPrimary,
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
    );

    return InkWell(
      onTap: disabled
          ? null
          : () {
              if (tristate) {
                onChanged!(value == null ? false : (value! ? null : true));
              } else {
                onChanged!(!(value ?? false));
              }
            },
      borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: GeniusWalletConsts.space2,
          vertical: GeniusWalletConsts.space2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: box,
            ),
            const SizedBox(width: GeniusWalletConsts.space4),
            Flexible(child: text),
          ],
        ),
      ),
    );
  }
}
