import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_motion.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

class GWTextField extends StatelessWidget {
  const GWTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.inputFormatters,
    this.focusNode,
    this.textAlign = TextAlign.start,
    this.validator,
    this.borderless = false,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final String? hint;
  final String? helper;
  final String? errorText;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextAlign textAlign;
  final FormFieldValidator<String>? validator;

  /// Suppress the field's own hairline/focus stroke while KEEPING the fill and
  /// rounded shape — for when a parent draws the border itself (e.g.
  /// [GWSearchField]'s gradient focus ring). Default false: every other field
  /// keeps its normal borders byte-identically.
  final bool borderless;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this const-instanced widget to rebuild on a live appearance toggle.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: GeniusWalletTypography.labelMd.copyWith(
              color: gw.textSecondary,
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space4),
        ],
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          focusNode: focusNode,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          onTap: onTap,
          readOnly: readOnly,
          enabled: enabled,
          autofocus: autofocus,
          inputFormatters: inputFormatters,
          textAlign: textAlign,
          validator: validator,
          style: GeniusWalletTypography.bodyLg,
          cursorColor: GeniusWalletColors.brandPrimary,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GeniusWalletTypography.bodyLg.copyWith(
              color: gw.textSecondary,
            ),
            prefixIcon: prefix,
            suffixIcon: suffix,
            counterText: '',
            filled: true,
            fillColor: gw.surfaceElevated,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: GeniusWalletConsts.space8,
              vertical: GeniusWalletConsts.space8,
            ),
            border: borderless ? _noBorder : _border(gw.borderSubtle),
            enabledBorder: borderless ? _noBorder : _border(gw.borderSubtle),
            focusedBorder: borderless
                ? _noBorder
                : _border(GeniusWalletColors.brandPrimaryStrong, width: 2),
            errorBorder:
                borderless ? _noBorder : _border(GeniusWalletColors.statusError),
            focusedErrorBorder: borderless
                ? _noBorder
                : _border(GeniusWalletColors.statusError, width: 2),
            disabledBorder: borderless ? _noBorder : _border(gw.borderSubtle),
            errorText: errorText,
            errorStyle: GeniusWalletTypography.bodySm.copyWith(
              color: GeniusWalletColors.statusError,
            ),
            helperText: errorText == null ? helper : null,
            helperStyle: GeniusWalletTypography.bodySm.copyWith(
              color: gw.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(GeniusWalletConsts.radiusLg),
        borderSide: BorderSide(color: color, width: width),
      );

  /// Keeps the rounded fill but draws NO stroke — [borderless] mode, where a
  /// parent owns the visible border (the gradient focus ring).
  OutlineInputBorder get _noBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusLg),
        borderSide: BorderSide.none,
      );
}

/// Password input with a built-in show/hide toggle. Common enough in a wallet
/// app to deserve a first-class component.
class GWPasswordField extends StatefulWidget {
  const GWPasswordField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.autofocus = false,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final bool autofocus;
  final bool enabled;

  @override
  State<GWPasswordField> createState() => _GWPasswordFieldState();
}

class _GWPasswordFieldState extends State<GWPasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return GWTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      helper: widget.helper,
      errorText: widget.errorText,
      obscureText: _obscured,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      suffix: IconButton(
        tooltip: _obscured ? 'Show' : 'Hide',
        icon: Icon(
          _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
          color: gw.textSecondary,
        ),
        onPressed: () => setState(() => _obscured = !_obscured),
      ),
    );
  }
}

class GWSearchField extends StatefulWidget {
  const GWSearchField({
    super.key,
    this.controller,
    this.hint = 'Search',
    this.onChanged,
    this.onClear,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool autofocus;

  @override
  State<GWSearchField> createState() => _GWSearchFieldState();
}

class _GWSearchFieldState extends State<GWSearchField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final focused = _focusNode.hasFocus;

    // The focus highlight is the BRAND GRADIENT ring, not the flat blue the
    // default focusedBorder draws. Standard gradient-border trick: an outer
    // container carries the gradient (focus) / hairline (rest) as its fill, and
    // the border-width padding around the inner borderless+filled field is the
    // only place that fill shows — a 2px gradient ring on focus, a 1px hairline
    // at rest. AnimatedContainer cross-fades the two.
    return AnimatedContainer(
      duration: GeniusWalletMotion.fast,
      curve: GeniusWalletMotion.standard,
      padding: EdgeInsets.all(focused ? 2 : 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusLg),
        gradient: focused ? GeniusWalletGradient.brandCta : null,
        color: focused ? null : gw.borderSubtle,
      ),
      child: GWTextField(
        controller: widget.controller,
        hint: widget.hint,
        autofocus: widget.autofocus,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        borderless: true,
        prefix: Icon(
          Icons.search,
          size: 20,
          color: gw.textSecondary,
        ),
        suffix: widget.onClear != null
            ? IconButton(
                tooltip: 'Clear',
                icon: Icon(
                  Icons.close,
                  size: 18,
                  color: gw.textSecondary,
                ),
                onPressed: widget.onClear,
              )
            : null,
      ),
    );
  }
}
