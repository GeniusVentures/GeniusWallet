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
                children: [
                  Flexible(child: titleText),
                  ?titleTrailing,
                  const Spacer(),
                  ?trailing,
                ],
              ),
        if (subtitleText != null) ...[
          const SizedBox(height: GeniusWalletConsts.space2),
          subtitleText,
        ],
      ],
    );

    // The glyph sits beside the whole block, not inside the title Row, so it
    // centres against title + subtitle together. `Expanded` keeps the trailing
    // widget pinned to the right edge exactly as it is without a leading.
    final Widget identityBlock = leading == null
        ? titleBlock
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              leading!,
              const SizedBox(width: GeniusWalletConsts.space6),
              Expanded(child: titleBlock),
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
