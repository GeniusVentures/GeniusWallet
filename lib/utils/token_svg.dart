import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_svg/flutter_svg.dart';

final _cssRule = RegExp(r'\.([\w-]+)\s*\{([^}]*)\}');

/// Inlines `<style>` class fills, which flutter_svg ignores (USDC drew black).
/// Throws on a bitmap used as a `<pattern>` fill (BASE, DAI+, CRV), which it
/// draws as nothing, so the caller shows the letters instead of a blank disc.
String sanitizeTokenSvg(String svg) {
  if (svg.contains('<pattern') && svg.contains('<image')) {
    throw const FormatException('SVG fills with a bitmap pattern');
  }
  var out = svg;
  for (final rule in _cssRule.allMatches(svg)) {
    final style = rule.group(2)!.trim();
    out = out.replaceAll('class="${rule.group(1)}"', 'style="$style"');
  }
  return out;
}

/// Network SVG loader that runs [sanitizeTokenSvg] on the downloaded text.
class TokenSvgLoader extends SvgNetworkLoader {
  const TokenSvgLoader(super.url);

  @override
  String provideSvg(Uint8List? message) =>
      sanitizeTokenSvg(utf8.decode(message!, allowMalformed: true));
}
