import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';

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

  static List<BoxShadow> glowBrand = [
    BoxShadow(
      color: GeniusWalletColors.brandPrimary.withAlpha(46), // ~18%
      blurRadius: 24,
    ),
  ];

  /// Cyan→mint glow used under hero CTAs to echo the brand gradient.
  static List<BoxShadow> glowGradient = [
    BoxShadow(
      color: GeniusWalletColors.brandPrimary.withAlpha(38),
      blurRadius: 28,
      offset: const Offset(-6, 8),
    ),
    BoxShadow(
      color: GeniusWalletColors.brandSecondary.withAlpha(38),
      blurRadius: 28,
      offset: const Offset(6, 8),
    ),
  ];
}
