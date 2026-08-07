import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// The header height every panel reserves, so the title (and single-line
/// trailings) centre in the same space whether the trailing is one line, two
/// lines, or absent.
///
/// 44 is a RESERVATION, not a measurement: the title's own line box is 24
/// ([kGWSectionTitleLineHeight]), and the difference is the centring slack
/// [kGWSectionTitleSlack] names. Every one of the eight sections spends it the
/// same way, which is the whole point of the number being here rather than at
/// a call site.
const double kGWSectionTitleHeaderHeight = 44;

/// The title's own line box: `titleLg` is 18/24, so 24.
const double kGWSectionTitleLineHeight = 24;

/// The whitespace the 44px reservation contributes on EACH side of the title's
/// line box, before any padding is charged at all.
///
/// This is the term every previous comment in this codebase missed, and it is
/// half the reason the rhythm drifted: `(44 - 24) / 2 = 10`.
const double kGWSectionTitleSlack =
    (kGWSectionTitleHeaderHeight - kGWSectionTitleLineHeight) / 2;

/// The pad charged ABOVE the reserved header. **Frozen** - it is half of R1
/// (`edgePad + slack = 12`), the box->title gap, which Jakub fixed as an input
/// on 2026-08-06 ("zachowaj padding ktory jest uzyty box vs title").
///
/// Off-grid, inherited rather than introduced: the `2` comes from sketch 004
/// (`padding: 2px space4 space8`).
const double kGWSectionTitleEdgePad = 2;

/// The RENDERED distance from the title's line box down to the first PAINTED
/// pixel below it - the number this component now holds constant.
///
/// 26, which is what the old `slack(10) + space8(16)` already produced for
/// content with no inset of its own. Nothing got louder; what changed is that
/// every OTHER section now renders 26 too.
const double kGWSectionTitleRenderedGap = 26;

/// Shared dashboard-PANEL section title (18px `titleLg`) - left-aligned,
/// `space4` horizontal inset, optional right-aligned [trailing].
///
/// This is NOT [GWPageHeader]: that is the full-PAGE title (24px `headlineLg`,
/// Column). GWSectionTitle is the smaller panel analogue.
///
/// ## The rule: hold the RENDERED gap, not the padding
///
/// The distance below the title is the sum of three terms, only one of which
/// this widget used to control:
///
/// ```
/// R2 = slack(10) + bottomPad + contentTopInset
/// ```
///
/// A fixed `bottomPad` therefore makes R2 depend on the CONTENT - and it did,
/// badly. Measured 2026-08-06 across the eight call sites, a constant `space8`
/// bottom pad rendered 26, 34, 38, 43 and 46 depending on whether the first
/// thing below the title was a `GWCard` (no inset), a padded row, a table
/// header, or a `ListTile` (which snaps to a default tile height and CENTRES
/// its content, contributing slack nobody declared anywhere). That spread is
/// what Jakub read on the phone as "the titles do not sit in a consistent
/// rhythm".
///
/// So the constant is moved one level up: the call site declares its content's
/// [contentTopInset] and this widget spends its own pad against it, leaving
///
/// ```
/// bottomPad = max(0, kGWSectionTitleRenderedGap - slack - contentTopInset)
/// R2        = kGWSectionTitleRenderedGap, for every contentTopInset <= 16
/// ```
///
/// **Do not "simplify" this back to a fixed bottom pad.** A fixed pad looks
/// tidier and silently reintroduces the C-dependence this arithmetic exists to
/// remove - and it fails silently, because nothing throws when a gap drifts.
/// `test/components/gw_section_title_rhythm_test.dart` pins it.
///
/// ## Why 26 below and 12 above is the SYMMETRIC answer, not a compromise
///
/// R1 (box->title) is 12 in layout terms and R2 is 26, which reads lopsided on
/// paper and balanced on glass. Two terms the layout numbers omit:
///
/// ```
/// visual above = hostCardPad(12) + edgePad(2) + slack(10) + cap-inset(~4) ~= 28
/// visual below = slack(10) + bottomPad + contentTopInset + descent(~5)    ~= 31
/// ```
///
/// The host card's own `space6` padding sits directly above the title and the
/// eye reads it as part of the border->title gap; below the title there is no
/// such contribution. Measured on Jakub's iPhone 2026-08-06: Assets 28.9pt
/// above / 31.3pt below, judged balanced and named as the target. Compute at
/// the same moment measured 17.7pt below and read visibly bottom-tight - that
/// is the panel this rule fixes.
///
/// ## [contentTopInset] above 16
///
/// The pad floors at zero, so content whose own inset exceeds 16 overshoots to
/// `slack + contentTopInset`. ONE site does: the Markets panel's `ListTile`
/// rows, at ~16.75. Those rows are NOT to be normalised - forcing tile heights
/// would change row-to-row rhythm, divider spacing and touch targets across
/// three panels, and the overshoot is under a pixel of what the shared gap
/// would render anyway.
///
/// Assets was the SECOND such site, at ~20, until 2026-08-07. Its first content
/// was a `CoinCardRow` `ListTile`, and the overshoot was the look Jakub had
/// measured on the phone as already correct. Sketch 178 scheme A then put the
/// portfolio total in a band between the title and those rows, and a band
/// paints at its own top pixel, so Assets declares nothing here now and renders
/// the shared 26 like every other section. The row's snap did not go away; it
/// stopped being the FIRST thing under the title, which is the only thing this
/// parameter has ever described.
///
/// Call sites must not add their own minHeight or their own spacer below the
/// title - the component owns both.
///
/// ## One shape, and the parameter that briefly was not
///
/// This component carried an optional `titleBlock` for part of 2026-08-07,
/// which let the Assets panel paint a composite left side (sketch 178 scheme
/// C) instead of its name. Jakub rejected that scheme on device the same day
/// and Assets went back to the plain `String` path, leaving the parameter with
/// zero consumers, so it was removed with the scheme rather than left standing
/// as a supported pattern. Look for `titleBlock` in the 2026-08-07 history
/// before re-adding it: this component's entire job is to give eight sections
/// ONE shape, and a second left-hand path that no call site exercises works
/// against that.
class GWSectionTitle extends StatelessWidget {
  const GWSectionTitle({
    super.key,
    required this.title,
    this.trailing,
    this.contentTopInset = 0,
  });

  /// The section's name, rendered as the 18px `titleLg` left side.
  final String title;

  final Widget? trailing;

  /// The first-content widget's OWN top inset: the distance from its layout
  /// box's top edge to its first painted pixel.
  ///
  /// A MEASURED figure, not a spacing choice, which is why it is not required
  /// to sit on the 4-pt grid - it describes what the content already does. The
  /// resulting bottom PAD is what must land on the grid, and at every current
  /// call site it does: `space8` (16) for C=0, `space4` (8) for C=8, `space2`
  /// (4) for C=12, and 0 for the two ListTile rows that overshoot.
  final double contentTopInset;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this subtree to rebuild on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    // Clamped at 0: a content inset above 16 cannot buy negative padding, it
    // just overshoots the rendered gap. See the class doc.
    final double bottomPad = math.max(
      0,
      kGWSectionTitleRenderedGap - kGWSectionTitleSlack - contentTopInset,
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(
        GeniusWalletConsts.space4,
        kGWSectionTitleEdgePad,
        GeniusWalletConsts.space4,
        bottomPad,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: kGWSectionTitleHeaderHeight,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // A single title child (no trailing) left-aligns via spaceBetween.
            // The title Text stays UNWRAPPED (matches the Assets reference);
            // overflow-prone trailings are handled at the call site.
            Text(
              title,
              style: GeniusWalletTypography.titleLg.copyWith(
                color: gw.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
