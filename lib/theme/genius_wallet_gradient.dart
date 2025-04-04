import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

class GeniusWalletGradient {
  static LinearGradient greenBlueGreenGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      GeniusWalletColors.btnGradientBlue,
      GeniusWalletColors.btnGradientGreen
    ],
  );
}
