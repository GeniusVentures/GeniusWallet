import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/utils/token_svg.dart';

void main() {
  test('a stylesheet logo falls back rather than drawing black', () {
    const svg =
        '<svg><style>.st0{fill:#2775CA;}</style><circle class="st0" r="1"/></svg>';
    expect(() => sanitizeTokenSvg(svg), throwsFormatException);
  });

  test('a bitmap pattern logo falls back rather than drawing blank', () {
    const svg =
        '<svg><rect fill="url( \'#p\' )"/><defs><pattern id="p"><use href="#i"/></pattern>'
        '<image id="i" href="data:image/png;base64,AA"/></defs></svg>';
    expect(() => sanitizeTokenSvg(svg), throwsFormatException);
  });

  test('a plain vector logo, even with an embedded image, is untouched', () {
    const svg =
        '<svg><circle r="1"/><image href="data:image/png;base64,AA"/></svg>';
    expect(sanitizeTokenSvg(svg), svg);
  });
}
