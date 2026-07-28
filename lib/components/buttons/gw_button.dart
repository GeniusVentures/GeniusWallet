import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_motion.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

enum GWButtonVariant {
  primary,
  secondary,
  tertiary,
  ghost,
  destructive,
  icon,

  /// Hero / signature CTA — green→blue gradient lifted from the gnus.ai site.
  gradient,

  /// Outline twin of [gradient] — transparent fill, gradient border + label
  /// (painted via a srcIn ShaderMask over the brand CTA gradient). Pairs with
  /// a [gradient] primary so both CTAs share one gradient identity.
  gradientOutline,
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
    this.height,
  }) : assert(
         label != null || leading != null,
         'GWButton needs a label or a leading widget',
       ),
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
  }) : label = null,
       leading = null,
       trailing = null,
       expand = false,
       height = null;

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
  // ponytail: local additive height override so a single call site (top-bar
  // Buy GNUS) can render at 40 without a global GWButtonSize regression --
  // default null preserves every existing size-based height app-wide.
  final double? height;

  bool get _isIconOnly => icon != null;

  double get _height {
    if (height != null) {
      return height!;
    }
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
    if (_isIconOnly) {
      return 0;
    }
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

  // Fail-soft read: registers the InheritedWidget dependency that forces
  // this const-instanced widget to rebuild on a live appearance toggle. `gw`
  // is threaded in from build() so _palette() stays a plain method.
  _Palette _palette(GWColors gw) {
    switch (variant) {
      case GWButtonVariant.primary:
        // App-wide primary CTA now paints the brand CTA gradient (was the flat
        // neon brandPrimary fill) — single central edit propagates everywhere.
        return _Palette(
          background: GeniusWalletColors.gradientBlue,
          // Near-black on the bright CTA gradient (white failed WCAG AA).
          foreground: GeniusWalletColors.textOnBrand,
          border: null,
          gradient: GeniusWalletGradient.brandCta,
        );
      case GWButtonVariant.secondary:
        // Appearance-aware on-surface outline + text (was the flat neon
        // accent, then a raw brandPrimaryStrong that missed AA against
        // light's surfaceBase). One central edit → every secondary CTA
        // app-wide. In light mode this takes the pairing from 1.93:1 on
        // surfaceBase to 4.76:1 -- the case that forced the darker light
        // token value. Dark is unchanged (token == brandPrimaryStrong there).
        return _Palette(
          background: Colors.transparent,
          foreground: GeniusWalletColors.brandPrimaryOnSurface,
          border: BorderSide(
            color: GeniusWalletColors.brandPrimaryOnSurface,
            width: 1.5,
          ),
        );
      case GWButtonVariant.tertiary:
        return _Palette(
          background: gw.surfaceElevated,
          foreground: gw.textPrimary,
          border: BorderSide(color: gw.borderSubtle),
        );
      case GWButtonVariant.ghost:
        return _Palette(
          background: Colors.transparent,
          foreground: gw.textPrimary,
          border: null,
        );
      case GWButtonVariant.destructive:
        return _Palette(
          background: GeniusWalletColors.statusError,
          foreground: gw.textPrimary,
          border: null,
        );
      case GWButtonVariant.icon:
        return _Palette(
          background: gw.surfaceElevated,
          foreground: gw.textPrimary,
          border: BorderSide(color: gw.borderSubtle),
        );
      case GWButtonVariant.gradient:
        return _Palette(
          background: GeniusWalletColors.gradientBlue,
          // Near-black on the bright CTA gradient (white failed WCAG AA).
          foreground: GeniusWalletColors.textOnBrand,
          border: null,
          gradient: GeniusWalletGradient.brandCta,
        );
      case GWButtonVariant.gradientOutline:
        // Border + label are painted opaque white then recolored by a srcIn
        // ShaderMask in build(); the transparent fill stays transparent under
        // the mask. Values here are pre-mask placeholders.
        return _Palette(
          background: Colors.transparent,
          foreground: Colors.white,
          border: const BorderSide(color: Colors.white, width: 1.5),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final palette = _palette(gw);
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
              if (label != null)
                const SizedBox(width: GeniusWalletConsts.space4),
            ] else if (leading != null) ...[
              IconTheme.merge(
                data: IconThemeData(color: fg, size: _iconSize()),
                child: leading!,
              ),
              if (label != null)
                const SizedBox(width: GeniusWalletConsts.space4),
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
              if (label != null)
                const SizedBox(width: GeniusWalletConsts.space4),
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
        borderRadius: BorderRadius.circular(
          _isIconOnly ? _height / 2 : GeniusWalletConsts.radiusLg,
        ),
        border: palette.border != null
            ? Border.fromBorderSide(palette.border!)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
            _isIconOnly ? _height / 2 : GeniusWalletConsts.radiusLg,
          ),
          onTap: disabled ? null : onPressed,
          // "łapka" — pointer cursor on the enabled CTA; deferred when
          // disabled so it falls back to the natural (basic) cursor.
          mouseCursor: disabled
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          // Option A · Brighten (approved): the bright gradient fill swallows
          // the default Material ripple, so we paint an explicit white wash on
          // hover/press. Only the two gradient variants override the overlay;
          // every other variant keeps InkWell's default hover behavior.
          overlayColor: _overlay(disabled),
          child: child,
        ),
      ),
    );

    // Recolor the opaque border + label with the brand CTA gradient; the
    // transparent fill is untouched (srcIn keeps zero-alpha pixels clear).
    Widget masked = button;
    if (variant == GWButtonVariant.gradientOutline) {
      masked = ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) =>
            (disabled
                    ? LinearGradient(
                        begin: GeniusWalletGradient.brandCta.begin,
                        end: GeniusWalletGradient.brandCta.end,
                        colors: GeniusWalletGradient.brandCta.colors
                            .map((c) => c.withAlpha(140))
                            .toList(),
                      )
                    : GeniusWalletGradient.brandCta)
                .createShader(bounds),
        child: button,
      );
    }

    Widget wrapped = masked;
    if (expand && !_isIconOnly) {
      wrapped = SizedBox(width: double.infinity, child: masked);
    }
    if (tooltip != null) {
      wrapped = Tooltip(message: tooltip!, child: wrapped);
    }
    if (semanticLabel != null) {
      wrapped = Semantics(label: semanticLabel, button: true, child: wrapped);
    }
    return wrapped;
  }

  // Approved hover = option A · Brighten. A white wash on hover/press reads as
  // a brightening of the gradient fill. Returns null for non-gradient variants
  // so they defer to InkWell's default overlay (no regression to secondary/
  // ghost/etc.). ponytail: gradientOutline's whole subtree is recolored by a
  // srcIn ShaderMask, so this white overlay is repainted with the brand
  // gradient — kept very low so it reads as a faint brand tint, not a wash.
  // Ceiling: the outline reaction is a tint (not a true brighten); upgrade
  // path = lift the overlay outside the mask if a stronger reaction is wanted.
  WidgetStateProperty<Color?>? _overlay(bool disabled) {
    final double hover;
    final double press;
    switch (variant) {
      case GWButtonVariant.primary:
      case GWButtonVariant.gradient:
        hover = 0.12;
        press = 0.18;
        break;
      case GWButtonVariant.gradientOutline:
        hover = 0.04;
        press = 0.06;
        break;
      default:
        return null; // defer to InkWell default
    }
    return WidgetStateProperty.resolveWith((states) {
      if (disabled) {
        return Colors.transparent;
      }
      if (states.contains(WidgetState.pressed)) {
        return Colors.white.withValues(alpha: press);
      }
      if (states.contains(WidgetState.hovered)) {
        return Colors.white.withValues(alpha: hover);
      }
      return null;
    });
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
