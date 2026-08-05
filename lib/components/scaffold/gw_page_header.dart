import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// Shared in-body page-title header. Renders a left-aligned `headlineLg`
/// title (with an optional trailing action) and OWNS the gap below it — the
/// screen that mounts this should not add its own spacer after it.
class GWPageHeader extends StatelessWidget {
  const GWPageHeader({
    super.key,
    required this.title,
    this.trailing,
    this.subtitle,
    this.leading,
    this.titleTrailing,
    this.centered = false,
    this.trailingHugsTitle = false,
  });

  final String title;
  final Widget? trailing;

  /// Optional glyph before the title, vertically centred against the WHOLE
  /// identity block (title + subtitle) rather than against the title line - a
  /// coin's logo beside a name with a symbol under it reads as belonging to
  /// both, which is how `markets_hero_card` and `markets_table` already place
  /// theirs.
  ///
  /// **One consumer, and that is deliberate.** This is under the 3+ promotion
  /// bar `GWKicker`, `GWSelectRow` and `GWWarningNote` each had to clear, but
  /// the alternative is not a local widget - it is the coin page hand-rolling
  /// a title row again, which is the exact thing this component exists to stop
  /// and which 071-B deleted. Additive and defaulted to null, so every
  /// existing caller renders the identical tree.
  ///
  /// Pass this only on the left-aligned form. With [centered] the glyph sits
  /// left of the centred column and the text centres in what is left, which is
  /// not what a centred header wants; no caller does that today.
  final Widget? leading;

  /// Sits immediately after the title, **on the title's own line** - not below
  /// it with the subtitle, and not at the far right where [trailing] goes.
  ///
  /// Jakub, 2026-07-28: *"powinny być w jednej linii z tytułem, w tej samej
  /// linii."* The title row is laid out `CrossAxisAlignment.center`, so this
  /// and the title share a vertical centre however tall [trailing] makes the
  /// row - which is what "the same line" means once the right-hand side is a
  /// two-line price block.
  ///
  /// **This is the SECOND coin-page-only slot on this component, and that is
  /// the honest cost of the choice.** The alternative is not a local widget -
  /// it is the coin page hand-rolling its own title row again, which is the
  /// thing this component exists to stop and which 071-B deleted. Both slots
  /// are additive and null-defaulted, so no other caller's tree changes.
  final Widget? titleTrailing;

  /// Centres the title (and subtitle) instead of left-aligning it, with
  /// [trailing] pinned to the right edge. For the focused-form tabs (Swap,
  /// Feedback) whose header sits INSIDE the centred column rather than in the
  /// page's left gutter. Defaults to false, so the content tabs
  /// (Transactions / Markets / News) render exactly what they render today.
  final bool centered;

  /// Pulls [trailing] up against the title instead of pushing it to the far
  /// right edge (sketch 168 E1, Jakub 2026-07-31).
  ///
  /// Default false, so every existing caller keeps the edge-to-edge header it
  /// was written for. Only the coin page opts in: there the trailing is the
  /// coin's PRICE, which belongs to the name it sits beside, and separating
  /// the two by the full width of the page made the eye travel ~1200px to
  /// connect two facts about the same token.
  ///
  /// Has no effect when [centered] is true - that path puts the trailing in a
  /// `Stack` instead of the row, so there is nothing to hug.
  final bool trailingHugsTitle;

  /// Optional one-line subtitle rendered under the title row. Defaults to
  /// null so every existing caller (Transactions, Markets, News, and Swap as
  /// it stands today) renders exactly the widget tree it produces today —
  /// this parameter is additive-only.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this subtree to rebuild on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final titleText = Text(
      title,
      textAlign: centered ? TextAlign.center : TextAlign.start,
      style: GeniusWalletTypography.headlineLg.copyWith(color: gw.textPrimary),
    );
    final subtitleText = subtitle == null
        ? null
        : Text(
            subtitle!,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: GeniusWalletTypography.bodySm.copyWith(
              color: gw.textSecondary,
            ),
          );

    // Centred: a Stack, not a Row with a balancing SizedBox. The old swap
    // header balanced a 24px icon with a 24px box while the IconButton it sat
    // in is 48 wide, so the title was off-centre by half a hit target. A Stack
    // centres the text against the FULL width and lets the trailing widget be
    // any size without moving it.
    final Widget titleBlock = Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        centered
            ? titleText
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                // Default `MainAxisSize.max` claims the full width, which is
                // right for an edge-to-edge header and wrong for a hugging
                // one: with `trailingHugsTitle` the outer `Flexible` cannot
                // pull the trailing in while this Row is still expanding to
                // meet it, so the gap survives the outer fix (measured ~470px
                // on the coin page before this line existed).
                mainAxisSize: trailingHugsTitle
                    ? MainAxisSize.min
                    : MainAxisSize.max,
                children: [
                  // The only flex child here, so it gets ALL the space
                  // titleTrailing does not need and ellipsizes instead of
                  // overflowing once the row runs out.
                  Flexible(child: titleText),
                  ?titleTrailing,
                ],
              ),
        if (subtitleText != null) ...[
          const SizedBox(height: GeniusWalletConsts.space2),
          subtitleText,
        ],
      ],
    );

    // [leading] and [trailing] both sit beside the WHOLE identity block, not
    // inside the title Row, so both centre against title + subtitle together.
    //
    // For [trailing] that placement is also what keeps the subtitle tight.
    // Inside the title Row it set the ROW's height, and with
    // `CrossAxisAlignment.center` a tall trailing - the coin page's two-line
    // price block is ~62px against a 32px title line - centred the title in
    // the row and parked ~15px of dead row between the title and the `space2`
    // spacer below it. Measured 19px where the token says 4. Out here the
    // column is exactly `title + space2 + subtitle` tall whatever the price
    // block does. See `gw_page_header_subtitle_gap_test.dart`.
    //
    // The identity takes ONE `Expanded` slot and [trailing] takes the rest, so
    // trailing lands on the row's right edge - the same edge the body below
    // the header uses. It must not be a flat `[Flexible(identity), Spacer,
    // trailing]` row: `Flexible` and `Spacer` both default to flex 1, so they
    // split the free space 50/50, and a LOOSE `Flexible` whose Text does not
    // spend its whole allowance leaves the remainder parked at the END of the
    // row (default `MainAxisAlignment.start`). That is why "Updated now ⟳"
    // stopped near the middle of a 1900px window while the search field under
    // it spanned the full width.
    //
    // With [centered] the trailing goes in the Stack below instead, so the
    // centred text centres on the full width rather than on what is left.
    final bool trailingBesideIdentity = !centered && trailing != null;
    final Widget identityBlock = leading == null && !trailingBesideIdentity
        ? titleBlock
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: GeniusWalletConsts.space6),
              ],
              // [trailingHugsTitle] is the whole difference between the two
              // arrangements. `Expanded` makes the title claim every spare
              // pixel, which is what pins the trailing to the far right edge -
              // on a 1536px coin page that put ~1200px of empty row between a
              // coin's name and its price. `Flexible` lets the title take only
              // what it needs, so the trailing lands immediately after it and
              // the `Spacer` absorbs the remainder instead.
              //
              // Flexible, not `mainAxisSize: min`: a long title must still be
              // allowed to shrink and ellipsize rather than overflow the row.
              if (trailingHugsTitle)
                Flexible(child: titleBlock)
              else
                Expanded(child: titleBlock),
              if (trailingBesideIdentity) trailing!,
              if (trailingHugsTitle) const Spacer(),
            ],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (centered && trailing != null)
          Stack(
            alignment: Alignment.centerRight,
            children: [
              // Full width, so the centred text centres on the column and not
              // on whatever space the trailing widget leaves over.
              SizedBox(width: double.infinity, child: identityBlock),
              trailing!,
            ],
          )
        else
          SizedBox(width: double.infinity, child: identityBlock),
        const SizedBox(height: GeniusWalletConsts.space8),
      ],
    );
  }
}
