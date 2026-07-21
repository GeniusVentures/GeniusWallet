import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// Shared 40px shell for the top-bar right-cluster (sketch 005 winner B).
/// Plain `ButtonStyle` builders -- NOT a new widget/abstraction -- applied
/// locally to each of the five existing controls. Never touch
/// `theme.dart`'s `textButtonTheme`; that's shared app-wide (the trap).
///
/// Height is pinned via BOTH `minimumSize` and `maximumSize` (not
/// `fixedSize`+`Size.fromHeight`, which is infinite-width and blows up an
/// unbounded `Row`). `tapTargetSize: shrinkWrap` removes Material's 48px
/// tap-target floor. `visualDensity: standard` is pinned EXPLICITLY (not
/// left to the theme default): on desktop the ambient
/// `adaptivePlatformDensity` is `compact`, whose `-8` baseSizeAdjustment
/// lowers `minHeight` to 32 while `maxHeight` stays 40 -- so the short chip
/// content (icon+label, no vertical padding) collapsed to ~32px, a visible
/// 8px shorter than Buy GNUS's hard 40. Standard density keeps the
/// constraints at [40, 40] so the chip renders exactly 40, matching Buy GNUS.
ButtonStyle navChipShell(BuildContext context) {
  return TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(
      horizontal: GeniusWalletConsts.space6,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
    ),
    minimumSize: const Size(0, 40),
    maximumSize: const Size(double.infinity, 40),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.standard,
  );
}

/// Quiet context-chip style (chain / SDK / wallet controls): the shell plus
/// `gw.surfaceMenu` fill and a state-aware border -- rest = `borderSubtle`,
/// hover = `borderStrong`. The hover wiring MUST be a
/// `WidgetStateProperty.resolveWith` on `side`; `styleFrom`'s plain `side`
/// arg is not state-aware.
ButtonStyle navContextChipStyle(BuildContext context) {
  final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
  return navChipShell(context).copyWith(
    backgroundColor: WidgetStatePropertyAll(gw.surfaceMenu),
    foregroundColor: WidgetStatePropertyAll(gw.textPrimary),
    side: WidgetStateProperty.resolveWith(
      (states) => BorderSide(
        color: states.contains(WidgetState.hovered)
            ? gw.borderStrong
            : gw.borderSubtle,
        width: 1,
      ),
    ),
  );
}

/// Appearance-aware Connect brand color. Dark keeps `brandPrimaryStrong`
/// (clears AA on the dark `surfaceElevated`, 0xFF0C0E14). Light uses a
/// darker brand so the outline+label clear AA on light's pure-white
/// `surfaceElevated` -- raw `brandPrimaryStrong` is only ~2.1:1 there.
/// Reuses the existing `GWAppearance.isLight` signal (no new one invented).
Color connectBrandColor(BuildContext context) {
  return GWAppearance.isLight
      ? const Color(0xFF0B6E8F)
      : GeniusWalletColors.brandPrimaryStrong;
}
