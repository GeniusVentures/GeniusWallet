import 'package:flutter/material.dart';
import 'package:genius_wallet/components/effects/gw_hoverable.dart';
import 'package:genius_wallet/components/gw_control_track.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_elevation.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

/// 1H·1D·1W·1M·1Y segmented control (sketch 006 `.tf`), extracted from
/// `dashboard_screen.dart`'s private `_TimeframeSegment` — this is now the
/// THIRD occurrence in the codebase (dashboard, the coin-page/dashboard chart
/// header, and — before this extraction — a second, differently labelled copy
/// on the Markets hero), which is what makes the extraction correct under the
/// Rule of Three (`AGENTS.md`).
///
/// The default label set and the track are both settled by evidence, not
/// taste (sketch 078 README §3): Robinhood's own documented set is the "1X"
/// grammar (`1H/1D/1W/1M/1Y`), and the control-track convention
/// (`.planning/codebase/CONVENTIONS.md`, "Control track") calls for a recessed
/// `surfaceSunken` well, not a raised `surfaceMenu` chip.
///
/// **Uncontrolled, plus an optional callback — not fully controlled.** Tapping
/// a tab always moves the selected chip locally; [onChanged], when supplied,
/// additionally reports the tapped index so a consumer can react (re-fetch,
/// re-window a series). The dashboard and coin-page chart header pass no
/// callback, so they stay exactly as visual as before. The Markets hero
/// (`markets_hero_card.dart`, quick 260807-bxs) is the first consumer that
/// does, closing
/// `.planning/todos/pending/2026-07-24-unify-timeframe-segment-component.md`
/// with its own `24H/7D/30D/1Y` [labels] — the reason this stays uncontrolled
/// rather than gaining a required `selectedIndex` is that a failed fetch
/// should leave the tapped tab selected and show the error in the chart box
/// instead, which a controlled component would make the parent responsible
/// for re-deriving.
class GWTimeframeSegment extends StatefulWidget {
  const GWTimeframeSegment({
    super.key,
    this.initialIndex = 1,
    this.labels = const ['1H', '1D', '1W', '1M', '1Y'],
    this.onChanged,
  });

  /// Which tab starts selected. Defaults to index 1 ('1D'), matching the
  /// sketch's default.
  final int initialIndex;

  /// The tab labels, in order. Defaults to the sketch's "1X" grammar.
  final List<String> labels;

  /// Reports the tapped index, after the chip has already moved. Null (the
  /// default) keeps a consumer purely visual — the dashboard and coin-page
  /// call sites pass none, and this widget renders byte-identically for them.
  final ValueChanged<int>? onChanged;

  @override
  State<GWTimeframeSegment> createState() => _GWTimeframeSegmentState();
}

class _GWTimeframeSegmentState extends State<GWTimeframeSegment> {
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    // Geometry lives in GWControlTrack now (`lib/components/gw_control_track.dart`)
    // - the same container as the transactions filter bar
    // (`transactions_slim_view.dart`'s `_TransactionFilterBar`), the Buy
    // GNUS orders track and the Compute panel's balance unit track
    // (`260731-kc5`), so the four can no longer drift apart by editing one
    // file.
    return GWControlTrack(
      children: [
        for (var i = 0; i < widget.labels.length; i++)
          _TimeframeTab(
            label: widget.labels[i],
            selected: i == _selected,
            // Selected chip wears the brand CTA gradient with textOnBrand
            // (near-black) -- AA-safe in BOTH modes, so no light-mode fallback
            // is needed. Hover raises an unselected tab onto surfaceElevated.
            // textMutedOnSunken, not textSecondary: this label paints
            // directly on the track's surfaceSunken well, where
            // textSecondary measures 4.23:1 in light mode.
            unselectedColor: gw.textMutedOnSunken,
            hoverColor: gw.surfaceElevated,
            hoverTextColor: gw.textPrimary,
            onTap: () {
              setState(() => _selected = i);
              widget.onChanged?.call(i);
            },
          ),
      ],
    );
  }
}

/// Hover plumbing moved into `GWHoverable` (23-05); this widget held no other
/// state, so it is a `StatelessWidget` now.
class _TimeframeTab extends StatelessWidget {
  const _TimeframeTab({
    required this.label,
    required this.selected,
    required this.unselectedColor,
    required this.hoverColor,
    required this.hoverTextColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color unselectedColor;
  final Color hoverColor;
  final Color hoverTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GWHoverable(
      builder: (hovered) {
        // Unselected label: muted normally, lifts to hoverTextColor on hover.
        final Color labelColor = selected
            ? context.gw.textOnBrand
            : (hovered ? hoverTextColor : unselectedColor);

        // Design-system hover = "lift chip" (sketch 008 variant D): an
        // unselected tab rises onto surfaceElevated with the card shadow and
        // a 1px lift, so hover and the selected gradient chip share a raised
        // material.
        final bool lifted = hovered && !selected;
        // Material's InkWell, not a GestureDetector: it takes focus and
        // activates on Enter/Space, which is what makes the tab reachable
        // without a pointer (WCAG 2.1.1, Level A). `hoverColor` is cleared
        // because the hover response is the lift above, not an overlay -- the
        // same shape `_UnitSegment` in compute_panel.dart already uses.
        return Semantics(
          button: true,
          selected: selected,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              hoverColor: Colors.transparent,
              borderRadius: BorderRadius.circular(
                GeniusWalletConsts.radiusPill,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                transformAlignment: Alignment.center,
                transform: lifted
                    ? Matrix4.translationValues(0, -1, 0)
                    : Matrix4.identity(),
                padding: const EdgeInsets.symmetric(
                  horizontal: GeniusWalletConsts.space4,
                  vertical: GeniusWalletConsts.space3,
                ),
                decoration: BoxDecoration(
                  gradient: selected ? GeniusWalletGradient.brandCta : null,
                  color: selected
                      ? null
                      : (lifted ? hoverColor : Colors.transparent),
                  borderRadius: BorderRadius.circular(
                    GeniusWalletConsts.radiusPill,
                  ),
                  boxShadow: (selected || lifted)
                      ? GeniusWalletElevation.card
                      : null,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
