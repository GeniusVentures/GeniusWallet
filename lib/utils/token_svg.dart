import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_svg/flutter_svg.dart';

/// Throws for logos flutter_svg draws wrongly, so the caller shows the letters
/// instead: `<style>` classes are ignored (USDC turned black) and a bitmap
/// used as a `<pattern>` fill is drawn as nothing (BASE, DAI+, CRV).
String sanitizeTokenSvg(String svg) {
  if (svg.contains('<style') ||
      (svg.contains('<pattern') && svg.contains('<image'))) {
    throw const FormatException('SVG uses features flutter_svg cannot draw');
  }
  return svg;
}

/// Network SVG loader that runs [sanitizeTokenSvg] on the downloaded text.
class TokenSvgLoader extends SvgNetworkLoader {
  const TokenSvgLoader(super.url);

  @override
  String provideSvg(Uint8List? message) =>
      sanitizeTokenSvg(utf8.decode(message!, allowMalformed: true));
}
