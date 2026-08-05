import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// The app's uppercase section label — `TODAY`, `TRANSACTION`, `MARKET CAP`.
///
/// Before sketch 065 this existed in FIVE places and was hand-written in every
/// one. They agreed on weight (w600) and colour (textSecondary) and disagreed
/// on size (10 / 11 / 13) and tracking (0.4 / 0.5 / 0.6 / 0.7 / 0.88). Two
/// steps replace all five: one size cannot serve both a section title that
/// stands alone above a group and a column header inside a width-constrained
/// table — at 13px `MARKET CAP` widens the Markets column, at 11px a section
/// title goes too quiet.
///
/// Tracking rises WITH the step on purpose. At uppercase the optical gap
/// between letters grows with the size, so two steps want two values rather
/// than one averaged one.
///
/// This is NOT [GWSectionTitle]: that is the 18px `titleLg` PANEL header which
/// owns a 44px reserved min-height and its own bottom gap. GWKicker owns no
/// padding at all — the call site places it, because its five homes sit at five
/// different insets.
class GWKicker extends StatelessWidget {
  const GWKicker(this.label, {super.key, this.dense = false, this.trailing});

  /// Written as given; the widget upper-cases it. Call sites must NOT pre-call
  /// `toUpperCase()` — a label that arrives already upper-cased reads
  /// identically here but loses its original casing for screen readers.
  final String label;

  /// 11px step for dense and tabular contexts (column headers, stat captions).
  /// Default 13px is the section-title step.
  final bool dense;

  /// Right-aligned companion (a count, a chevron).
  ///
  /// Sketch 065 also drew variant D — the same kicker with a hairline running
  /// to the right edge — and it was NOT chosen (C, two steps, no rule). No
  /// `rule` flag is carried here for a picture nothing renders; if D is ever
  /// wanted it is an `Expanded(Container(height: 1, color: gw.borderSubtle))`
  /// in this Row.
  final Widget? trailing;

  /// The shared text style, for call sites that need the TYPE but not the
  /// widget — an interactive label carrying its own hover, active state or
  /// trailing geometry (the sortable column header, the View-all link). Those
  /// stay their own widgets; taking the widget here would force it to grow
  /// hover, an active state and two trailing shapes, at which point it stops
  /// being a label.
  static TextStyle style(GWColors gw, {bool dense = false}) =>
      GeniusWalletTypography.labelMd.copyWith(
        color: gw.textSecondary,
        fontWeight: FontWeight.w600,
        fontSize: dense ? 11 : 13,
        height: dense ? 16 / 11 : 18 / 13,
        letterSpacing: dense ? 0.6 : 0.5,
      );

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces this
    // subtree to rebuild on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final text = Text(label.toUpperCase(), style: style(gw, dense: dense));

    if (trailing == null) {
      return text;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [text, trailing!],
    );
  }
}
