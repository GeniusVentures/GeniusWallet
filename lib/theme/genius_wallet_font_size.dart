// Legacy holdout: `GeniusWalletTypography` (lib/theme/genius_wallet_typography.dart) is the
// unified type scale for this codebase and exposes styled `TextStyle` getters, not bare
// fontSize doubles at these exact values, so its 3 call sites (registration_header.dart,
// continue_button/isactive_false.dart, continue_button/isactive_true.dart) still build their
// own `TextStyle`s and need a raw double. Reduced to the 2 members those call sites actually
// use -- Phase 22-03 found `base` and both `sectionHeader*` aliases had zero references
// anywhere in the repo. Revisit when those 3 sites migrate onto a single type scale.
class GeniusWalletFontSize {
  static const double medium = 16.0;
  static const double title = 20.0;
}
