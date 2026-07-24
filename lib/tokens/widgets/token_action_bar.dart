import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// Compact token-screen action bar — the redesign's `.actbtn` row from
/// sketch 152 (`.planning/sketches/152-token-detail-responsive`). Replaces the
/// larger, squarer [ActionButton] on the token detail screen with four
/// COMPACT boxes (icon over a small label) laid out in an equal-width [Row].
///
/// Visual states map 1:1 to the sketch:
///   - `.actbtn.on`  → Receive: a subtle brand gradient fill, transparent
///                     border, brand glyph, primary-text label.
///   - `.actbtn`     → an enabled box (More): `surfaceMenu` fill, hairline
///                     border, brand glyph, secondary-text label.
///   - `.actbtn.off` → a disabled box (Send / Swap / gated More): recessed
///                     `surfaceSunken` fill, transparent border, glyph + label
///                     lowered to `textPrimary54` — visibly disabled yet still
///                     legible (WCAG AA) in BOTH dark and light modes.
///
/// The bar is pure presentation: it exposes callbacks + enabled flags so the
/// screen wires behaviour. Send / Swap default to the disabled treatment; More
/// renders disabled unless [onMore] is supplied (finding-37). Receive is always
/// the primary "on" affordance.
class TokenActionBar extends StatelessWidget {
  /// Tapped when Receive is pressed. Receive always renders as the primary
  /// "on" button; when null it simply performs no action.
  final VoidCallback? onReceive;

  /// Tapped when More is pressed. When null, More renders disabled ("off").
  final VoidCallback? onMore;

  /// Whether Send is interactive. Defaults to disabled — the token screen has
  /// no send flow yet, so Send renders as an inert (but legible) "off" box.
  final bool sendEnabled;

  /// Whether Swap is interactive. Defaults to disabled for the same reason.
  final bool swapEnabled;

  /// Tapped when Send is pressed (only fires when [sendEnabled] is true).
  final VoidCallback? onSend;

  /// Tapped when Swap is pressed (only fires when [swapEnabled] is true).
  final VoidCallback? onSwap;

  const TokenActionBar({
    super.key,
    required this.onReceive,
    required this.onMore,
    this.sendEnabled = false,
    this.swapEnabled = false,
    this.onSend,
    this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    // A Send/Swap button is only live when its *Enabled flag is set AND a
    // callback was supplied; otherwise it renders the disabled "off" style.
    final bool sendLive = sendEnabled && onSend != null;
    final bool swapLive = swapEnabled && onSwap != null;
    final bool moreLive = onMore != null;

    return Row(
      children: [
        Expanded(
          child: _ActButton(
            icon: Icons.qr_code_2,
            label: 'Receive',
            variant: _ActVariant.primary,
            onTap: onReceive,
          ),
        ),
        const SizedBox(width: GeniusWalletConsts.space4),
        Expanded(
          child: _ActButton(
            icon: Icons.north_east,
            label: 'Send',
            variant: sendLive ? _ActVariant.enabled : _ActVariant.disabled,
            onTap: sendLive ? onSend : null,
          ),
        ),
        const SizedBox(width: GeniusWalletConsts.space4),
        Expanded(
          child: _ActButton(
            icon: Icons.swap_horiz,
            label: 'Swap',
            variant: swapLive ? _ActVariant.enabled : _ActVariant.disabled,
            onTap: swapLive ? onSwap : null,
          ),
        ),
        const SizedBox(width: GeniusWalletConsts.space4),
        Expanded(
          child: _ActButton(
            icon: Icons.more_horiz,
            label: 'More',
            variant: moreLive ? _ActVariant.enabled : _ActVariant.disabled,
            onTap: moreLive ? onMore : null,
          ),
        ),
      ],
    );
  }
}

/// The three visual treatments a compact action button can take (see the
/// [TokenActionBar] doc comment for how each maps to the sketch CSS).
enum _ActVariant { primary, enabled, disabled }

/// A single compact `.actbtn`: a Column of [icon, gap, label] in a bordered,
/// rounded box. Stateful only to lift 2px on hover for the two interactive
/// treatments (matches the sketch's `translateY(-2px)` + brand border).
class _ActButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final _ActVariant variant;
  final VoidCallback? onTap;

  const _ActButton({
    required this.icon,
    required this.label,
    required this.variant,
    required this.onTap,
  });

  @override
  State<_ActButton> createState() => _ActButtonState();
}

class _ActButtonState extends State<_ActButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read registers the InheritedWidget dependency so the button
    // re-skins on a live appearance toggle.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    final bool isDisabled = widget.variant == _ActVariant.disabled;
    final bool isPrimary = widget.variant == _ActVariant.primary;
    final bool canHover = !isDisabled && widget.onTap != null;
    final bool lifted = canHover && _hovered;

    // Fill: gradient for the primary "on" button, recessed for disabled,
    // surfaceMenu for a normal enabled box.
    final Gradient? fillGradient = isPrimary
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              // .actbtn.on → linear-gradient(135deg,
              //   rgba(10,216,156,.16), rgba(10,174,230,.16))
              GeniusWalletColors.gradientGreen.withValues(alpha: 0.16),
              GeniusWalletColors.gradientBlue.withValues(alpha: 0.16),
            ],
          )
        : null;
    final Color? fillColor = isPrimary
        ? null
        : isDisabled
            ? gw.surfaceSunken
            : gw.surfaceMenu;

    // Border: hairline only on the normal enabled box; the primary + disabled
    // boxes carry a transparent border. Hover promotes an enabled box's border
    // to the brand accent.
    final Color borderColor = isPrimary || isDisabled
        ? Colors.transparent
        : lifted
            ? GeniusWalletColors.brandPrimary
            : gw.borderSubtle;

    // Glyph: brand accent on the interactive treatments (appearance-aware, WCAG
    // AA in both modes); lowered but legible on the disabled box.
    final Color glyphColor = isDisabled
        ? gw.textPrimary54
        : GeniusWalletColors.brandPrimaryOnSurface;

    // Label: primary text for the "on" button and hovered boxes; secondary for
    // a resting enabled box; lowered-but-legible for the disabled box.
    final Color labelColor = isDisabled
        ? gw.textPrimary54
        : (isPrimary || lifted)
            ? gw.textPrimary
            : gw.textSecondary;

    Widget box = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, lifted ? -2 : 0, 0),
      padding: const EdgeInsets.symmetric(
        vertical: GeniusWalletConsts.space6, // 12px
        horizontal: GeniusWalletConsts.space4, // 8px
      ),
      decoration: BoxDecoration(
        color: fillColor,
        gradient: fillGradient,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusSm),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: 20, color: glyphColor),
          const SizedBox(height: GeniusWalletConsts.space3), // 6px
          Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: labelColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    box = Semantics(
      button: true,
      enabled: !isDisabled && widget.onTap != null,
      label: widget.label,
      child: box,
    );

    return MouseRegion(
      cursor: canHover ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: canHover ? (_) => setState(() => _hovered = true) : null,
      onExit: canHover ? (_) => setState(() => _hovered = false) : null,
      child: GestureDetector(
        onTap: widget.onTap,
        child: box,
      ),
    );
  }
}
