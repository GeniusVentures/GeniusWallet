import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

class GeniusWalletElevation {
  GeniusWalletElevation._();

  static List<BoxShadow> get card => [
    BoxShadow(
      color: GWAppearance.isLight
          ? const Color(0x1F000000) // rgba(0,0,0,0.12)
          : const Color(0x59000000), // rgba(0,0,0,0.35)
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get dialog => [
    BoxShadow(
      color: GWAppearance.isLight
          ? const Color(0x33000000) // rgba(0,0,0,0.20)
          : const Color(0x73000000), // rgba(0,0,0,0.45)
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];

  // brandPrimary/brandSecondary are fixed (mode-invariant), so either
  // GWColors instance works -- .dark() picked arbitrarily, matching
  // GWDecorations' own context-free static access pattern.
  static List<BoxShadow> glowBrand = [
    BoxShadow(
      color: GWColors.dark().brandPrimary.withAlpha(46), // ~18%
      blurRadius: 24,
    ),
  ];

  /// Cyan→mint glow used under hero CTAs to echo the brand gradient.
  static List<BoxShadow> glowGradient = [
    BoxShadow(
      color: GWColors.dark().brandPrimary.withAlpha(38),
      blurRadius: 28,
      offset: const Offset(-6, 8),
    ),
    BoxShadow(
      color: GWColors.dark().brandSecondary.withAlpha(38),
      blurRadius: 28,
      offset: const Offset(6, 8),
    ),
  ];
}
