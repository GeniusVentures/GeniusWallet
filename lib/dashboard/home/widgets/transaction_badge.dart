import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// The nine badge identities: all seven `TransactionType` values plus the two
/// non-happy-path statuses. Phase 12's single source of truth — the row
/// (12-03) and the filter chips (12-04) both read [badgeSpec], so a Mint chip
/// can never show a different mark from a Mint row.
enum TransactionBadgeKind {
  sent,
  received,
  mint,
  job,
  escrow,
  swap,
  purchase,
  pending,
  failed,
}

/// Fill + glyph + accessible label for one badge kind.
@immutable
class TransactionBadgeSpec {
  const TransactionBadgeSpec({
    required this.fill,
    required this.label,
    this.icon,
    this.svgAsset,
  }) : assert(
         (icon == null) != (svgAsset == null),
         'exactly one of icon/svgAsset must be set',
       );

  final Color fill;
  final IconData? icon;
  final String? svgAsset;
  final String label;
}

/// The badge table. Fills marked `gw.*` are appearance-aware; the rest are
/// mode-invariant statics (safe because they are only ever FILLS).
TransactionBadgeSpec badgeSpec(TransactionBadgeKind kind, GWColors gw) {
  switch (kind) {
    case TransactionBadgeKind.sent:
      return const TransactionBadgeSpec(
        fill: GWColors.statusNeutral,
        icon: Icons.north_east,
        label: 'Sent',
      );
    case TransactionBadgeKind.received:
      return TransactionBadgeSpec(
        fill: gw.statusSuccess,
        icon: Icons.south_west,
        label: 'Received',
      );
    case TransactionBadgeKind.mint:
      // Sketch 012 recommended the server for Mint; Jakub overrode it. The
      // pickaxe is on MINT and the server is on JOB — do not re-litigate.
      return TransactionBadgeSpec(
        fill: gw.brandTertiary,
        svgAsset: 'assets/images/pickaxe.svg',
        label: 'Mint',
      );
    case TransactionBadgeKind.job:
      // Icons.dns is Material's server rack — matches the sketch's two
      // stacked rects, so no FontAwesome import is needed.
      return TransactionBadgeSpec(
        fill: gw.brandPrimaryStrong,
        icon: Icons.dns,
        label: 'Job',
      );
    case TransactionBadgeKind.escrow:
      return const TransactionBadgeSpec(
        fill: GWColors.statusNeutral,
        icon: Icons.lock,
        label: 'Escrow',
      );
    case TransactionBadgeKind.swap:
      // Not in the ROADMAP badge table (it enumerates only the seven locked
      // ones) — fill/glyph come from sketch 014's live TX rows.
      return const TransactionBadgeSpec(
        fill: GWColors.statusNeutral,
        icon: Icons.swap_horiz,
        label: 'Swapped',
      );
    case TransactionBadgeKind.purchase:
      // Also from sketch 014's live rows, not the ROADMAP table.
      return TransactionBadgeSpec(
        fill: gw.statusSuccess,
        icon: Icons.credit_card,
        label: 'Purchased',
      );
    case TransactionBadgeKind.pending:
      return TransactionBadgeSpec(
        fill: gw.statusWarning,
        icon: Icons.schedule,
        label: 'Pending',
      );
    case TransactionBadgeKind.failed:
      return TransactionBadgeSpec(
        fill: gw.statusError,
        icon: Icons.close,
        label: 'Failed',
      );
  }
}

/// Whichever of white / ink reads better ON [fill]. Computed, never a
/// hand-maintained per-kind table: `statusSuccess` flips from `#0AD89C`
/// (dark — ink wins, ~10.7:1) to `#07875F` (light — white wins, ~4.5:1), so a
/// fixed glyph colour would silently fail one appearance.
///
/// Sketch 011's finding is that the badge is a filled circle with a
/// knocked-out glyph, so glyph-vs-FILL is the ratio that gates AA — not
/// fill-vs-surface. A hardcoded white glyph on `statusError` is exactly the
/// regression quick task 260720-k81 shipped and 05-VERIFICATION logged as
/// Gap 1.
Color badgeGlyphColor(Color fill, GWColors gw) {
  final lf = fill.computeLuminance();
  double ratio(Color c) {
    final lc = c.computeLuminance();
    return (lc > lf ? (lc + 0.05) / (lf + 0.05) : (lf + 0.05) / (lc + 0.05));
  }

  return ratio(Colors.white) >= ratio(gw.textOnBrand)
      ? Colors.white
      : gw.textOnBrand;
}

/// Paints [spec]'s glyph, whether it is an [IconData] or an SVG asset.
/// Exists because 12-04's filter chips must paint the SAME mark as the row
/// badge, and one of the nine glyphs (the pickaxe) is an SVG — so callers
/// cannot just read `spec.icon`.
Widget badgeGlyph(
  TransactionBadgeSpec spec, {
  required Color color,
  double size = 11,
}) {
  if (spec.icon != null) {
    return Icon(spec.icon, size: size, color: color);
  }
  return SvgPicture.asset(
    spec.svgAsset!,
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
  );
}

/// 18px filled circle with a knocked-out glyph.
///
/// The ring defaults to the panel surface so the badge reads as a hole punched
/// through the coin art behind it — it is deliberately NOT white; a white ring
/// is the k81/Gap-1 regression.
///
/// Every dimension is a fixed literal on purpose: commit 37639d5 fixed an app
/// freeze caused by a size derived continuously from available height. Nothing
/// here may be derived from `constraints`.
class TransactionBadge extends StatelessWidget {
  const TransactionBadge({super.key, required this.kind, this.ringColor});

  final TransactionBadgeKind kind;
  final Color? ringColor;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final spec = badgeSpec(kind, gw);
    return Semantics(
      label: spec.label,
      child: Container(
        width: 18,
        height: 18,
        // Align, not tight constraints: an SvgPicture handed a tight 18x18
        // would stretch past the ring instead of sitting at its own 11px.
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: spec.fill,
          shape: BoxShape.circle,
          border: Border.all(color: ringColor ?? gw.surfaceElevated, width: 2),
        ),
        child: badgeGlyph(
          spec,
          color: badgeGlyphColor(spec.fill, gw),
          size: 11,
        ),
      ),
    );
  }
}
