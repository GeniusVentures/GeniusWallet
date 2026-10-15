import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_svg/flutter_svg.dart';

final _cssRule = RegExp(r'\.([\w-]+)\s*\{([^}]*)\}');

/// Makes a Squid token SVG safe for flutter_svg, which ignores `<style>`
/// classes (USDC paints as a black disc) and draws nothing for logos that
/// wrap an embedded bitmap in a `<pattern>` (BASE, DAI+). Throws on the latter
/// so the caller shows the letters fallback instead of an empty hole.
String sanitizeTokenSvg(String svg) {
  if (svg.contains('<image')) {
    throw const FormatException('SVG wraps an embedded bitmap');
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
