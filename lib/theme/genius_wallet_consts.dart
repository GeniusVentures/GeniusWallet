class GeniusWalletConsts {
  static const int pinCount = 4;

  // ---------------------------------------------------------------------------
  // Spacing scale (4-pt grid). Use these instead of hardcoded EdgeInsets values.
  // ---------------------------------------------------------------------------
  static const double space2 = 4.0;
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
  // (`--radius: .625rem`); pair with `radius2xl` / `radius3xl` for cards.
  // ---------------------------------------------------------------------------
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusBase = 10.0; // gnus.ai default
  static const double radiusMd = 12.0;
  static const double radiusLg = 15.0;
  static const double radius2xl = 16.0; // gnus.ai --radius-2xl
  static const double radiusXl = 24.0;
  static const double radius3xl = 24.0; // gnus.ai --radius-3xl alias
  static const double radiusPill = 48.0;

  // ---------------------------------------------------------------------------
  // Legacy aliases (kept for backwards compatibility).
  // ---------------------------------------------------------------------------
  static const double horizontalPadding = space10;
  static const double horizontalDesktopPadding = space20;
  static const double verticalDesktopPadding = space20;
  static const double itemSpacing = space8;
  static const double borderRadiusCard = radiusLg;
  static const double borderRadiusButton = radiusPill;
  static const double appBarHeight = 65;
}
