import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

/// Brand-styled dropdown selector. Wraps Material's [DropdownButtonFormField]
/// with the GNUS surface / radius / focus tokens so callers don't reinvent
/// styling per screen.
///
/// ```dart
/// GWSelect<Currency>(
///   label: 'Currency',
///   value: selected,
///   items: currencies.map((c) => GWSelectItem(value: c, label: c.symbol)).toList(),
///   onChanged: (c) => setState(() => selected = c),
/// )
/// ```
class GWSelect<T> extends StatelessWidget {
  const GWSelect({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.enabled = true,
    this.expand = true,
    this.leading,
  });

  final T? value;
  final List<GWSelectItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? hint;
  final String? helper;
  final String? errorText;
  final bool enabled;
  final bool expand;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final field = DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: expand,
      onChanged: enabled ? onChanged : null,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: GeniusWalletColors.textSecondary,
      ),
      dropdownColor: context.gw.surfaceMenu,
      borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusLg),
      style: GeniusWalletTypography.bodyLg,
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item.value,
              enabled: item.enabled,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.leading != null) ...[
                    item.leading!,
                    const SizedBox(width: GeniusWalletConsts.space4),
                  ],
                  Flexible(
                    child: Text(
                      item.label,
                      style: GeniusWalletTypography.bodyLg.copyWith(
                        color: item.enabled
                            ? context.gw.textPrimary
                            : context.gw.textTertiary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GeniusWalletTypography.bodyLg.copyWith(
          color: context.gw.textSecondary,
        ),
        prefixIcon: leading,
        filled: true,
        fillColor: context.gw.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: GeniusWalletConsts.space8,
          vertical: GeniusWalletConsts.space8,
        ),
        border: _border(context.gw.borderSubtle),
        enabledBorder: _border(context.gw.borderSubtle),
        focusedBorder: _border(context.gw.brandPrimaryStrong, width: 2),
        errorBorder: _border(context.gw.statusError),
        focusedErrorBorder: _border(context.gw.statusError, width: 2),
        disabledBorder: _border(context.gw.borderSubtle),
        errorText: errorText,
        errorStyle: GeniusWalletTypography.bodySm.copyWith(
          color: context.gw.statusError,
        ),
        helperText: errorText == null ? helper : null,
        helperStyle: GeniusWalletTypography.bodySm.copyWith(
          color: context.gw.textSecondary,
        ),
      ),
    );

    if (label == null) {
      return field;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label!,
          style: GeniusWalletTypography.labelMd.copyWith(
            color: context.gw.textSecondary,
          ),
        ),
        const SizedBox(height: GeniusWalletConsts.space4),
        field,
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusLg),
        borderSide: BorderSide(color: color, width: width),
      );
}

class GWSelectItem<T> {
  const GWSelectItem({
    required this.value,
    required this.label,
    this.leading,
    this.enabled = true,
  });

  final T value;
  final String label;
  final Widget? leading;
  final bool enabled;
}
