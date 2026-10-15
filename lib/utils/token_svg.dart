import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:xml/xml.dart';

final _cssRule = RegExp(r'\.([\w-]+)\s*\{([^}]*)\}');
final _fillUrl = RegExp(r'url\(#([^)]+)\)');

/// Inlines `<style>` class fills, which flutter_svg ignores (USDC drew black).
/// Throws when a `<pattern>` holding a bitmap is used as a fill (BASE, DAI+,
/// CRV): flutter_svg draws nothing, so the caller shows the letters instead.
String sanitizeTokenSvg(String svg) {
  final doc = XmlDocument.parse(svg);
  final elements = doc.descendantElements.toList();

  final rules = {
    for (final style in elements.where((e) => e.name.local == 'style'))
      for (final m in _cssRule.allMatches(style.innerText))
        m.group(1)!: m.group(2)!.trim(),
  };
  for (final e in elements) {
    final classes = e.getAttribute('class')?.split(' ') ?? const <String>[];
    final declared = [
      for (final c in classes)
        if (rules[c] != null) rules[c]!,
    ];
    if (declared.isEmpty) {
      continue;
    }
    final inline = e.getAttribute('style');
    e.setAttribute('style', [...declared, ?inline].join(';'));
    e.removeAttribute('class');
  }

  final bitmapPatterns = {
    for (final p in elements.where((e) => e.name.local == 'pattern'))
      if (p.descendantElements.any((e) => e.name.local == 'image') ||
          _usesImage(p, elements))
        p.getAttribute('id'),
  };
  for (final e in elements) {
    final fills = '${e.getAttribute('fill')};${e.getAttribute('style')}';
    for (final m in _fillUrl.allMatches(fills)) {
      if (bitmapPatterns.contains(m.group(1))) {
        throw const FormatException('SVG fills with a bitmap pattern');
      }
    }
  }
  return doc.toXmlString();
}

/// A pattern that only `<use>`s an `<image>` defined elsewhere in the file.
bool _usesImage(XmlElement pattern, List<XmlElement> all) {
  final ids = {
    for (final u in pattern.descendantElements.where(
      (e) => e.name.local == 'use',
    ))
      for (final a in u.attributes)
        if (a.name.local == 'href') a.value.replaceFirst('#', ''),
  };
  return all.any(
    (e) => e.name.local == 'image' && ids.contains(e.getAttribute('id')),
  );
}

/// Network SVG loader that runs [sanitizeTokenSvg] on the downloaded text.
class TokenSvgLoader extends SvgNetworkLoader {
  const TokenSvgLoader(super.url);

  @override
  String provideSvg(Uint8List? message) =>
      sanitizeTokenSvg(utf8.decode(message!, allowMalformed: true));
}
