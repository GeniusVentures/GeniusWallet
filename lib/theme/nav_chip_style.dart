import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
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
    padding: const EdgeInsets.symmetric(horizontal: GeniusWalletConsts.space6),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
    ),
    minimumSize: const Size(0, 40),
    maximumSize: const Size(double.infinity, 40),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.standard,
  );
}

/// In-track chip style (chain / SDK / wallet controls): the navbar control
/// track for sketch 039-B ("jeden tor" -- one track). The three context
/// selectors sit inside one `surfaceSunken` + hairline `Container` (built in
/// `responsive_overlay.dart`'s `_buildActionRowWidgets`), matching the
/// `CONVENTIONS.md` -> Control track recipe already used by
/// `_TimeframeSegment` and `_TransactionFilterBar`. Ship this style together
/// with its track -- the chip alone (borderless, transparent) looks
/// unfinished without the track around it.
///
/// The chip itself carries NO fill and NO border at rest -- the track is the
/// one fill and the one hairline now. Height is **36**, so
/// 36 + 6px track padding + 2px track border == **44** -- the height of the
/// nav tab hover surface on the other side of the same bar. It was 32 (giving
/// a 40px track) until 2026-07-26, when the 12px gap against a 44px tab read
/// as "the dropdowns are too small" on a live walk. Hover is THE app-wide
/// recipe — brand tint + brand hairline, no geometry — read from
/// `GWDecorations.hoverFill` / `hoverEdge` (sketch 044 variant 3). It used to
/// be a bare `surfaceElevated` fill, which is why these controls read as inert
/// beside nav tabs that visibly rose.
ButtonStyle navContextChipStyle(BuildContext context) {
  final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
  return navChipShell(context).copyWith(
    minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
    maximumSize: const WidgetStatePropertyAll(Size(double.infinity, 36)),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: GeniusWalletConsts.space4),
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
      ),
    ),
    // THE app-wide hover recipe (sketch 044 variant 3): brand tint + brand
    // hairline, no geometry. Same two tokens the nav tabs and GWCard read, via
    // GWDecorations.hoverFill / hoverEdge -- so this bar cannot drift from the
    // rest of the app the way three separate hovers did.
    backgroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.hovered)
          ? GWDecorations.hoverFill
          : Colors.transparent,
    ),
    foregroundColor: WidgetStatePropertyAll(gw.textPrimary),
    side: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.hovered)
          ? BorderSide(color: GWDecorations.hoverEdge, width: 1)
          : BorderSide.none,
    ),
  );
}

/// Appearance-aware Connect brand color. Dark keeps `brandPrimaryStrong`
/// (clears AA on the dark `surfaceElevated`, 0xFF0C0E14). Light uses a
/// darker brand so the outline+label clear AA on light's pure-white
/// `surfaceElevated` -- raw `brandPrimaryStrong` is only 2.56:1 there.
/// Delegates to the shared `GeniusWalletColors.brandPrimaryOnSurface` token.
Color connectBrandColor(BuildContext context) {
  return GeniusWalletColors.brandPrimaryOnSurface;
}
