import 'package:flutter/painting.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// The EVM testnet icons are a white glyph, which vanishes on a light surface.
/// Colour logos that a testnet reuses are not white.
bool isWhiteNetworkIcon(String? iconPath) =>
    iconPath?.endsWith('-testnet.png') ?? false;

/// The text colour for a white network icon on a themed surface, else null.
Color? networkIconTint(GWColors gw, String? iconPath) =>
    isWhiteNetworkIcon(iconPath) ? gw.textPrimary : null;
