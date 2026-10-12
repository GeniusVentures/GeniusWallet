import 'package:flutter/painting.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// The EVM testnet icons are a white glyph, which vanishes on a light surface,
/// so they take the text colour. Colour logos that a testnet reuses do not.
Color? networkIconTint(GWColors gw, String? iconPath) =>
    (iconPath?.endsWith('-testnet.png') ?? false) ? gw.textPrimary : null;
