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
  });

  final String title;
  final Widget? trailing;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: GeniusWalletTypography.headlineLg.copyWith(
                color: gw.textPrimary,
              ),
            ),
            const Spacer(),
            ?trailing,
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: GeniusWalletConsts.space2),
          Text(
            subtitle!,
            style: GeniusWalletTypography.bodySm.copyWith(
              color: gw.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: GeniusWalletConsts.space8),
      ],
    );
  }
}
