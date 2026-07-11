import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';

class GeniusWalletElevation {
  GeniusWalletElevation._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x59000000), // rgba(0,0,0,0.35)
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> dialog = [
    BoxShadow(
      color: Color(0x73000000), // rgba(0,0,0,0.45)
      blurRadius: 32,
      offset: Offset(0, 8),
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
