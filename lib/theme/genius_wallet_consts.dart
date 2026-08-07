class GeniusWalletConsts {
  static const int pinCount = 4;

  static const double horizontalPadding = space10;
  static const double horizontalDesktopPadding = space20;

  static const double verticalDesktopPadding = space20;

  static const double itemSpacing = space8;

  static const double borderRadiusCard = radiusLg;
  static const double borderRadiusButton = radiusPill;

  static const double appBarHeight = 68;

  // ---------------------------------------------------------------------------
  // Spacing scale (4-pt grid). Use these instead of hardcoded EdgeInsets values.
  // ---------------------------------------------------------------------------
  static const double space2 = 4.0;
  // ponytail: space3 (6px) is a deliberate 2-pt half-step — the ONE token off the
  // otherwise-strict 4-pt grid. Added 2026-07-20 for the dashboard section-gap
  // rhythm, which read too tight at 4px and too loose at 8px. Ceiling: if more
  // half-steps get requested, the scale is drifting to 2-pt and the "4-pt grid"
  // label above should change; upgrade path is to formalise a 2-pt scale in
  // gnus-tokens.json rather than add space5/space7/... piecemeal.
  static const double space3 = 6.0;
  static const double space4 = 8.0;
  static const double space6 = 12.0;
  static const double space8 = 16.0;
  static const double space10 = 20.0;
  static const double space12 = 24.0;
  static const double space16 = 32.0;
  static const double space20 = 40.0;
  static const double space24 = 48.0;
  static const double space32 = 64.0;

  // ---------------------------------------------------------------------------
  // Radius tokens. `radiusBase` (10px) matches the gnus.ai default
  // (`--radius: .625rem`); pair with `radius2xl` / `radiusXl` for cards.
  // ---------------------------------------------------------------------------
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusBase = 10.0; // gnus.ai default
  static const double radiusMd = 12.0;
  static const double radiusLg = 15.0;
  static const double radius2xl = 16.0; // gnus.ai --radius-2xl
  static const double radiusXl = 24.0; // gnus.ai --radius-3xl
  static const double radiusPill = 48.0;
}

/// Ceiling on how much of the bottom safe-area inset a bottom-pinned chrome
/// surface reserves below its content.
///
/// Named for the job rather than for the tab bar, because it now has two
/// consumers: `_MobileTabBar` (`responsive_overlay.dart`) and the drawer
/// shell's footer (`responsive_drawer.dart`). It lives here, in the neutral
/// theme file, precisely so the drawer does not have to import a navigation
/// file to get it - and so the two cannot drift apart, which is the failure
/// this constant exists to prevent.
///
/// **Why 20 and not the raw 34 iOS reports.** 34 is the area iOS RESERVES for
/// the home indicator, not what the indicator NEEDS: the indicator itself is a
/// ~5pt bar whose top edge sits ~13pt above the screen bottom. 20 clears it
/// with room to spare and still keeps content outside the ~20pt band where the
/// system claims the swipe-up gesture, so nothing becomes harder to hit.
/// Devices with no home indicator report 0 and are unaffected - the cap only
/// ever removes, never adds.
///
/// 20 equals [GeniusWalletConsts.space10], so it is already on the 4-pt grid
/// and needs no exception.
const double kMaxBottomSafeInset = GeniusWalletConsts.space10;
