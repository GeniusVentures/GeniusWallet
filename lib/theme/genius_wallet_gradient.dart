import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';

class GeniusWalletGradient {
  static LinearGradient greenBlueGreenGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      GeniusWalletColors.btnGradientBlue,
      GeniusWalletColors.btnGradientGreen,
    ],
  );

  /// Primary CTA gradient — green (left) → blue (right).
  /// Mirrors the website's `linear-gradient(270deg, #0c91cc, #06aa78)`.
  static const LinearGradient brandCta = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      GeniusWalletColors.gradientGreen,
      GeniusWalletColors.gradientBlue,
    ],
  );

  /// Outline gradient used on bordered cards on the website
  /// (`linear-gradient(to right, var(--color-primary), #36edb5)`).
  static const LinearGradient brandBorder = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      GeniusWalletColors.brandPrimary,
      GeniusWalletColors.brandSecondaryBright,
    ],
  );

  /// Subtle background wash for hero sections — fades the brand teal into the
  /// darker contained surface so cards still feel anchored.
  static LinearGradient get heroWash => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          GeniusWalletColors.surfaceBase,
          GeniusWalletColors.surfaceElevated,
        ],
      );
}
