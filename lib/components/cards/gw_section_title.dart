import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// Shared dashboard-PANEL section title (18px `titleLg`). Captures the Assets
/// header's exact position — left-aligned, `space4` horizontal inset, `space8`
/// gap to the panel body, optional right-aligned [trailing] — so every panel
/// (Assets, Markets, Transactions, Bitcoin Chart) reads as one system.
///
/// This is NOT [GWPageHeader]: that is the full-PAGE title (24px `headlineLg`,
/// Column). GWSectionTitle is the smaller panel analogue and OWNS its own
/// `space8` bottom gap — the panel that mounts it should not add another spacer.
///
/// It also RESERVES a shared header min-height (~44 — the height the 2-line
/// Assets total needs: amount ~20/26 + 24h-change ~13/18) so all four panels
/// (Assets, Markets, Transactions, Bitcoin Chart) read at ONE geometry: an
/// identical title→panel-top padding AND title→first-row gap. Call sites must
/// not add their own minHeight — the component owns it.
class GWSectionTitle extends StatelessWidget {
  const GWSectionTitle({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this subtree to rebuild on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Padding(
      // The top 2 is a literal (sketch 004: `padding: 2px space4 space8`);
      // horizontal space4 + bottom space8 come from the shared token scale.
      padding: const EdgeInsets.fromLTRB(
        GeniusWalletConsts.space4,
        2,
        GeniusWalletConsts.space4,
        GeniusWalletConsts.space8,
      ),
      // ConstrainedBox reserves the shared header height for EVERY panel so the
      // title (and single-line trailings) center vertically in the same space
      // regardless of whether the trailing is one line, two lines, or absent.
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GeniusWalletTypography.titleLg.copyWith(
                color: gw.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            // A single title child (no trailing) left-aligns via spaceBetween.
            // The title Text stays unwrapped (matches the Assets reference);
            // overflow-prone trailings are handled at the call site.
            ?trailing,
          ],
        ),
      ),
    );
  }
}
