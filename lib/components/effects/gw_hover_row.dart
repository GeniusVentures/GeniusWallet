import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// How far a hovered row lifts off its own background.
///
/// 6% of the appearance's foreground, which is **one surface step**: measured
/// against a card (`surfaceElevated` #0C0E14) it lands at 1.135, and
/// `surfaceMenu` - the fill the chip hover already lifts onto - is 1.108 on the
/// same background. So a hovered row and a hovered chip read as the same
/// gesture at the same weight, without the row needing a second hover language.
///
/// It is deliberately louder than Flutter's stock `ThemeData.hoverColor`, which
/// is 4% (`0x0AFFFFFF`) and measures 1.086 - the value every row in this app
/// was inheriting, and the reason two of the three lists read as having no
/// hover at all.
const double kGWRowHoverAlpha = 0.06;

/// The one hover treatment for a full-width tappable ROW: a rounded highlight
/// across the whole row, a click cursor, and the framework's press feedback.
///
/// **Why rows get their own component rather than the "lift chip".** The hover
/// design system's standard response is D - rise onto `surfaceElevated`, take
/// the card shadow, lift 1px - and that is right for something that sits in a
/// track and can be pressed, like a nav tab or a timeframe chip. A row in a
/// list is a different affordance: it spans the panel, it has neighbours
/// directly above and below, and lifting it would make a list flicker as a
/// whole card every time the pointer crossed it. Rows express the same system
/// as a rounded highlight instead - the same reason `gw_view_all_link.dart`
/// keeps a gradient underline rather than being boxed into a chip.
///
/// **What this fixes, all three of which the 2026-07-30 walk found together:**
///
///  1. **Assets had no hover at all.** Its row is a `ListTile`, whose ink is
///     drawn on the nearest ancestor `Material`. On the dashboard that ancestor
///     sits BENEATH the panel's own painted background, so the highlight was
///     rendered and then covered. The local `Material` here is above every
///     caller's background by construction, so the highlight cannot be buried.
///  2. **Markets had square corners.** Its row is a bare `InkWell` with no
///     `borderRadius`, so the highlight painted as a full-bleed rectangle while
///     Transactions - the only one that passed `radiusMd` - painted rounded.
///  3. **All three inherited the theme's hover colour** rather than stating
///     one, so the strength of the feedback was whatever `ThemeData` happened
///     to default to.
///
/// The child arrives ALREADY PADDED. This owns the highlight, the radius, the
/// cursor and the tap; it does not own spacing, because its three callers have
/// three different row anatomies and a padding parameter here would just be
/// each of them passing its own value back.
class GWHoverRow extends StatelessWidget {
  const GWHoverRow({
    super.key,
    required this.child,
    this.onTap,
    this.radius = GeniusWalletConsts.radiusMd,
    this.semanticLabel,
  });

  final Widget child;

  /// A null [onTap] disables the highlight along with the tap - a row that does
  /// nothing must not claim it does.
  final VoidCallback? onTap;

  /// Rounded by default, at the same `radiusMd` the Transactions list already
  /// used and the one Jakub picked as the reference on 2026-07-30.
  final double radius;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces this
    // subtree to rebuild on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    // Derived from `textPrimary` rather than a new palette field: that token is
    // already white on dark and ink on light, which is exactly what a
    // foreground-tinted overlay needs, and a translucent overlay composites
    // correctly onto whatever the caller sits on. A fixed hover FILL could not
    // - these rows live on `surfaceElevated` in the dashboard panels and on
    // `surfaceBase` on the Markets page.
    final Color hover = gw.textPrimary.withValues(alpha: kGWRowHoverAlpha);

    final Widget row = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        hoverColor: hover,
        mouseCursor: onTap == null
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        child: child,
      ),
    );

    if (semanticLabel == null) {
      return row;
    }
    return Semantics(button: onTap != null, label: semanticLabel, child: row);
  }
}
