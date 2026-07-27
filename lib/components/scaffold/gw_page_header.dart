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
    this.centered = false,
  });

  final String title;
  final Widget? trailing;

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
                children: [titleText, const Spacer(), ?trailing],
              ),
        if (subtitleText != null) ...[
          const SizedBox(height: GeniusWalletConsts.space2),
          subtitleText,
        ],
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
              SizedBox(width: double.infinity, child: titleBlock),
              trailing!,
            ],
          )
        else
          SizedBox(width: double.infinity, child: titleBlock),
        const SizedBox(height: GeniusWalletConsts.space8),
      ],
    );
  }
}
