import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: GeniusWalletTypography.labelMd.copyWith(
              color: GeniusWalletColors.textSecondary,
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
              color: GeniusWalletColors.textSecondary,
            ),
            prefixIcon: prefix,
            suffixIcon: suffix,
            counterText: '',
            filled: true,
            fillColor: GeniusWalletColors.surfaceElevated,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: GeniusWalletConsts.space8,
              vertical: GeniusWalletConsts.space8,
            ),
            border: _border(GeniusWalletColors.borderSubtle),
            enabledBorder: _border(GeniusWalletColors.borderSubtle),
            focusedBorder: _border(GeniusWalletColors.brandPrimary, width: 2),
            errorBorder: _border(GeniusWalletColors.statusError),
            focusedErrorBorder:
                _border(GeniusWalletColors.statusError, width: 2),
            disabledBorder: _border(GeniusWalletColors.borderSubtle),
            errorText: errorText,
            errorStyle: GeniusWalletTypography.bodySm.copyWith(
              color: GeniusWalletColors.statusError,
            ),
            helperText: errorText == null ? helper : null,
            helperStyle: GeniusWalletTypography.bodySm.copyWith(
              color: GeniusWalletColors.textSecondary,
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
          color: GeniusWalletColors.textSecondary,
        ),
        onPressed: () => setState(() => _obscured = !_obscured),
      ),
    );
  }
}

class GWSearchField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GWTextField(
      controller: controller,
      hint: hint,
      autofocus: autofocus,
      onChanged: onChanged,
      prefix: const Icon(
        Icons.search,
        size: 20,
        color: GeniusWalletColors.textSecondary,
      ),
      suffix: onClear != null
          ? IconButton(
              icon: const Icon(
                Icons.close,
                size: 18,
                color: GeniusWalletColors.textSecondary,
              ),
              onPressed: onClear,
            )
          : null,
    );
  }
}
