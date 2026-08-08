import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:intl/intl.dart';

/// The portfolio total, in a full-width band of its own directly under the
/// Assets section title. Sketch 178 scheme A, 2026-08-07.
///
/// **PROMOTED out of `coins_screen.dart`'s private `_AssetsTotalBand`
/// (2026-08-08, quick 260808-whb)**, when `/assets` adopted sketch 187 scheme C
/// and needed the identical band inside its own panel. Two surfaces printing
/// one portfolio total is exactly the case where a copy drifts: the dashboard
/// panel and the page would sooner or later disagree about the type, the
/// colour or the optical centring of a number the user reads as one fact.
/// Nothing about the widget changed in the move - same tokens, same
/// `space4` inset, same `CrossAxisAlignment.center`.
///
/// A `StatelessWidget` rather than a `_buildBand()` helper, per AGENTS.md: it
/// gets its own element, its own rebuild boundary and its own type for a
/// finder to name.
class AssetsTotalBand extends StatelessWidget {
  const AssetsTotalBand({
    super.key,
    required this.total,
    required this.dayChange,
    required this.pctOfTotal,
  });

  final double total;
  final double dayChange;
  final double pctOfTotal;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this subtree to rebuild on a live appearance toggle.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final currencyFormatter = NumberFormat.currency(symbol: "\$");

    return Padding(
      // LOAD-BEARING, and the reason is structural: this band is a SIBLING of
      // `GWSectionTitle` in the parent Column, not a child of it, so it does
      // not inherit the title's own `space4` horizontal inset. Without this
      // padding the total hangs 8px to the left of the word Assets, which is
      // the one alignment the whole change is about.
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space4,
      ),
      child: Row(
        // CENTRE, not `baseline`. Jakub, 2026-08-07: "zmiana procentowa nie
        // jest wysrodkowana [...] chcialbym aby znajdowala sie na samym jej
        // srodku [...] troszeczke podniesiona do gory."
        //
        // Baseline alignment WAS the defect. It pins a 13px label's baseline
        // to a 24px number's baseline, so the label's figure body - which is
        // ~9.5 tall against the total's ~18 - hangs off the bottom of the
        // total's mass instead of sitting across its middle. Measured on real
        // Inter by pixel-scanning the painted ink (see the OPTICAL CENTRING
        // case in `assets_header_scheme_a_test.dart`): the percentage's figure
        // centre sat 4.13px BELOW the total's. `end` is worse at 5.63.
        //
        // `center` matches the two LINE BOXES' centres, and because both
        // children draw the same face at the same ascent:descent ratio, their
        // figure bodies land on the same centre too: measured residual 0.13px,
        // which is 0.39 of a device pixel at 3x. That is why there is no nudge
        // token here and must not be one - a hand-tuned offset would be a
        // literal standing in for a residual too small to see.
        //
        // Costs no height. `center` sizes the Row to max(32, 18) = 32, the
        // same 32 baseline alignment produced, so the 94px header holds.
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            currencyFormatter.format(total),
            // `numericHeadline` AS SHIPPED (24 / 32), with no `height`
            // override. Scheme C carried `height: 28 / 24` here and that
            // override was never a styling choice: it existed solely to make a
            // two-line block consume `GWSectionTitle`'s 44px reservation
            // exactly. There is no reservation to squeeze into any more, so
            // outside it the override is a bug rather than a feature - it would
            // only tighten this band's line box for no reason.
            //
            // 24 rather than the sketch's 28 for the same reason the band costs
            // 32 and not 36: there is no 28px token, and 28/32 and 24/32 have
            // the SAME 32px line box, so the on-token size is free.
            style: GeniusWalletTypography.numericHeadline.copyWith(
              fontWeight: FontWeight.w700,
              color: gw.textPrimary,
            ),
          ),
          // Guarded exactly as scheme C guarded it. The percentage's 18px line
          // box is shorter than the total's 32, and `center` sizes the Row to
          // the taller child, so this branch adds and removes WIDTH, never
          // height: the band measures 32 in both the funded and the all-zero
          // state. That was true under baseline alignment too and it survives
          // the switch, which is the reason the switch was safe to make.
          //
          // PERCENT ONLY here, still. The band has room for the dollar figure
          // the pre-2026-08-07 header carried (measured: it fits with 15.73px
          // to spare at `$1,234,567.89`), and restoring it is a named
          // follow-up, held back only so it does not confound the review of
          // the title treatment this change is actually for.
          if (total > 0) ...[
            const SizedBox(width: GeniusWalletConsts.space4),
            Text(
              '${dayChange >= 0 ? '+' : ''}${pctOfTotal.toStringAsFixed(2)}%',
              style: GeniusWalletTypography.labelMd.copyWith(
                color: dayChange >= 0 ? gw.statusSuccess : gw.statusError,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
