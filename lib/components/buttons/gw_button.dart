import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_motion.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

enum GWButtonVariant {
  primary,
  secondary,
  tertiary,
  ghost,
  destructive,
  icon,
  /// Hero / signature CTA — green→blue gradient lifted from the gnus.ai site.
  gradient,
}

enum GWButtonSize { sm, md, lg }

class GWButton extends StatelessWidget {
  const GWButton({
    super.key,
    required this.onPressed,
    this.label,
    this.leading,
    this.trailing,
    this.variant = GWButtonVariant.primary,
    this.size = GWButtonSize.md,
    this.isLoading = false,
    this.expand = false,
    this.tooltip,
    this.semanticLabel,
  })  : assert(label != null || leading != null,
            'GWButton needs a label or a leading widget'),
        icon = null;

  const GWButton.icon({
    super.key,
    required Widget this.icon,
    required this.onPressed,
    this.variant = GWButtonVariant.ghost,
    this.size = GWButtonSize.md,
    this.isLoading = false,
    this.tooltip,
    this.semanticLabel,
  })  : label = null,
        leading = null,
        trailing = null,
        expand = false;

  final String? label;
  final Widget? leading;
  final Widget? trailing;
  final Widget? icon;
  final VoidCallback? onPressed;
  final GWButtonVariant variant;
  final GWButtonSize size;
  final bool isLoading;
  final bool expand;
  final String? tooltip;
  final String? semanticLabel;

  bool get _isIconOnly => icon != null;

  double get _height {
    switch (size) {
      case GWButtonSize.sm:
        return 44; // was 36 — touch floor (iOS 44)
      case GWButtonSize.md:
        return 48;
      case GWButtonSize.lg:
        return 56;
    }
  }

  double get _horizontalPadding {
    if (_isIconOnly) return 0;
    switch (size) {
      case GWButtonSize.sm:
        return GeniusWalletConsts.space6;
      case GWButtonSize.md:
        return GeniusWalletConsts.space8;
      case GWButtonSize.lg:
        return GeniusWalletConsts.space10;
    }
  }

  TextStyle get _labelStyle {
    switch (size) {
      case GWButtonSize.sm:
        return GeniusWalletTypography.labelMd;
      case GWButtonSize.md:
        return GeniusWalletTypography.titleMd;
      case GWButtonSize.lg:
        return GeniusWalletTypography.titleLg;
    }
  }

  _Palette _palette() {
    switch (variant) {
      case GWButtonVariant.primary:
        return _Palette(
          background: GeniusWalletColors.brandPrimary,
          // Near-black on the bright cyan fill — white failed WCAG AA in dark
          // mode (~1.9:1). textOnBrand is the system's on-brand-fill color.
          foreground: GeniusWalletColors.textOnBrand,
          border: null,
        );
      case GWButtonVariant.secondary:
        return _Palette(
          background: Colors.transparent,
          foreground: GeniusWalletColors.brandPrimary,
          border: const BorderSide(
            color: GeniusWalletColors.brandPrimary,
            width: 1.5,
          ),
        );
      case GWButtonVariant.tertiary:
        return _Palette(
          background: GeniusWalletColors.surfaceElevated,
          foreground: GeniusWalletColors.textPrimary,
          border: BorderSide(color: GeniusWalletColors.borderSubtle),
        );
      case GWButtonVariant.ghost:
        return _Palette(
          background: Colors.transparent,
          foreground: GeniusWalletColors.textPrimary,
          border: null,
        );
      case GWButtonVariant.destructive:
        return _Palette(
          background: GeniusWalletColors.statusError,
          foreground: GeniusWalletColors.textPrimary,
          border: null,
        );
      case GWButtonVariant.icon:
        return _Palette(
          background: GeniusWalletColors.surfaceElevated,
          foreground: GeniusWalletColors.textPrimary,
          border: BorderSide(color: GeniusWalletColors.borderSubtle),
        );
      case GWButtonVariant.gradient:
        return _Palette(
          background: GeniusWalletColors.gradientBlue,
          // Near-black on the bright CTA gradient (white failed WCAG AA).
          foreground: GeniusWalletColors.textOnBrand,
          border: null,
          gradient: GeniusWalletGradient.brandCta,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette();
    final disabled = onPressed == null || isLoading;
    final hasGradient = palette.gradient != null;
    final bg = disabled && variant != GWButtonVariant.ghost
        ? palette.background.withAlpha(140)
        : palette.background;
    final fg = disabled
        ? palette.foreground.withAlpha(140)
        : palette.foreground;

    Widget child;
    if (_isIconOnly) {
      child = SizedBox(
        width: _height,
        height: _height,
        child: Center(
          child: isLoading
              ? _spinner(fg)
              : IconTheme.merge(
                  data: IconThemeData(color: fg, size: _iconSize()),
                  child: icon!,
                ),
        ),
      );
    } else {
      child = Padding(
        padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (isLoading) ...[
              _spinner(fg),
              if (label != null) const SizedBox(width: GeniusWalletConsts.space4),
            ] else if (leading != null) ...[
              IconTheme.merge(
                data: IconThemeData(color: fg, size: _iconSize()),
                child: leading!,
              ),
              if (label != null) const SizedBox(width: GeniusWalletConsts.space4),
            ],
            if (label != null)
              Flexible(
                child: Text(
                  label!,
                  style: _labelStyle.copyWith(color: fg),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            if (!isLoading && trailing != null) ...[
              if (label != null) const SizedBox(width: GeniusWalletConsts.space4),
              IconTheme.merge(
                data: IconThemeData(color: fg, size: _iconSize()),
                child: trailing!,
              ),
            ],
          ],
        ),
      );
    }

    final button = AnimatedContainer(
      duration: GeniusWalletMotion.fast,
      curve: GeniusWalletMotion.standard,
      height: _height,
      width: _isIconOnly ? _height : null,
      decoration: BoxDecoration(
        color: hasGradient ? null : bg,
        gradient: hasGradient
            ? (disabled
                ? LinearGradient(
                    begin: palette.gradient!.begin,
                    end: palette.gradient!.end,
                    colors: palette.gradient!.colors
                        .map((c) => c.withAlpha(140))
                        .toList(),
                  )
                : palette.gradient)
            : null,
        borderRadius:
            BorderRadius.circular(_isIconOnly ? _height / 2 : GeniusWalletConsts.radiusLg),
        border: palette.border != null
            ? Border.fromBorderSide(palette.border!)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
              _isIconOnly ? _height / 2 : GeniusWalletConsts.radiusLg),
          onTap: disabled ? null : onPressed,
          child: child,
        ),
      ),
    );

    Widget wrapped = button;
    if (expand && !_isIconOnly) {
      wrapped = SizedBox(width: double.infinity, child: button);
    }
    if (tooltip != null) {
      wrapped = Tooltip(message: tooltip!, child: wrapped);
    }
    if (semanticLabel != null) {
      wrapped = Semantics(label: semanticLabel, button: true, child: wrapped);
    }
    return wrapped;
  }

  Widget _spinner(Color color) => SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );

  double _iconSize() {
    switch (size) {
      case GWButtonSize.sm:
        return 16;
      case GWButtonSize.md:
        return 20;
      case GWButtonSize.lg:
        return 22;
    }
  }
}

class _Palette {
  _Palette({
    required this.background,
    required this.foreground,
    this.border,
    this.gradient,
  });
  final Color background;
  final Color foreground;
  final BorderSide? border;
  final LinearGradient? gradient;
}
