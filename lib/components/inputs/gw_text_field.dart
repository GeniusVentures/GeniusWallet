import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/components/inputs/gw_focus_ring.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_motion.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

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
    this.focusRing = false,
    this.fill,
    // IME-hardening opt-ins (06-04 §3.6). Every default below is Flutter's own
    // TextFormField stock default, so existing call sites — including
    // GWPasswordField and GWSearchField — behave byte-identically unless a
    // caller explicitly opts in. Key-bearing fields pass all four as false/none.
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.enableIMEPersonalizedLearning = true,
    this.textCapitalization = TextCapitalization.sentences,
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

  /// Wrap the input in [GWFocusRing], so focus is the brand GRADIENT instead of
  /// the flat `brandPrimaryStrong` stroke `focusedBorder` draws.
  ///
  /// A `BorderSide` takes a single `Color`, so no `InputBorder` can be a
  /// gradient -- which is why `GWFocusRing` exists at all. Its own doc names
  /// the rule: *"the app's accent IS the gradient"*, and a field painted flat
  /// blue is off-language in the one state where the app is most clearly
  /// speaking to the user.
  ///
  /// ponytail: OPT-IN, not the default, and that is a compromise rather than a
  /// design. Every one of this widget's eight call sites should arguably have
  /// it, but flipping the default re-skins Settings, News, Markets, the account
  /// manager and onboarding in one commit, which deserves its own walk. Ceiling:
  /// until then, two fields in the app light a gradient on focus and six light a
  /// flat blue. Upgrade path: flip this to true, delete the flag, walk the six.
  final bool focusRing;

  /// The fill inside the box. Defaults to `gw.surfaceElevated`, which is right
  /// on a page and WRONG on a drawer or dialog painted that same value -- see
  /// `ResponsiveDrawer`'s class doc for the 1.00:1 arithmetic.
  final Color? fill;

  /// See the constructor note. [enableIMEPersonalizedLearning] is the
  /// load-bearing one for key material — it maps to Android's
  /// `IME_FLAG_NO_PERSONALIZED_LEARNING`, the actual switch on the keyboard's
  /// learning store. The other three do not close that leak on their own.
  final bool autocorrect;
  final bool enableSuggestions;
  final bool enableIMEPersonalizedLearning;
  final TextCapitalization textCapitalization;

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
        _maybeRing(
          gw,
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
            autocorrect: autocorrect,
            enableSuggestions: enableSuggestions,
            enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
            textCapitalization: textCapitalization,
            style: GeniusWalletTypography.bodyLg,
            cursorColor: context.gw.brandPrimary,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GeniusWalletTypography.bodyLg.copyWith(
                color: gw.textSecondary,
              ),
              prefixIcon: prefix,
              suffixIcon: suffix,
              counterText: '',
              filled: true,
              fillColor: fill ?? gw.surfaceElevated,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: GeniusWalletConsts.space8,
                vertical: GeniusWalletConsts.space8,
              ),
              border: _borderless ? _noBorder : _border(gw.borderSubtle),
              enabledBorder: _borderless ? _noBorder : _border(gw.borderSubtle),
              focusedBorder: _borderless
                  ? _noBorder
                  : _border(context.gw.brandPrimaryStrong, width: 2),
              errorBorder: _borderless
                  ? _noBorder
                  : _border(context.gw.statusError),
              focusedErrorBorder: _borderless
                  ? _noBorder
                  : _border(context.gw.statusError, width: 2),
              disabledBorder: _borderless
                  ? _noBorder
                  : _border(gw.borderSubtle),
              errorText: errorText,
              errorStyle: GeniusWalletTypography.bodySm.copyWith(
                color: context.gw.statusError,
              ),
              helperText: errorText == null ? helper : null,
              helperStyle: GeniusWalletTypography.bodySm.copyWith(
                color: gw.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// [focusRing] implies [borderless]: the ring IS the border, and letting the
  /// `InputDecoration` draw its own inside it is the exact bug `GWFocusRing`'s
  /// doc warns about (`theme.dart`'s app-wide `focusedBorder` beats a local
  /// `border: InputBorder.none`, because a per-state border always beats the
  /// fallback).
  bool get _borderless => borderless || focusRing;

  Widget _maybeRing(GWColors gw, Widget field) {
    if (!focusRing) {
      return field;
    }
    return GWFocusRing(
      radius: GeniusWalletConsts.radiusLg,
      background: fill ?? gw.surfaceElevated,
      // The fill is a step from its canvas at best, so the edge carries WCAG
      // 1.4.11 on its own -- the same reasoning as the drawer fields.
      restingColor: errorText == null ? gw.borderControl : gw.statusError,
      enabled: enabled,
      child: field,
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusLg),
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
        prefix: Icon(Icons.search, size: 20, color: gw.textSecondary),
        suffix: widget.onClear != null
            ? IconButton(
                tooltip: 'Clear',
                icon: Icon(Icons.close, size: 18, color: gw.textSecondary),
                onPressed: widget.onClear,
              )
            : null,
      ),
    );
  }
}
