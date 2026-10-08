import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/swap/swap_token.dart';

SwapToken _token(String? logo) => SwapToken(
  chainId: '1',
  address: '0x0',
  name: 'Token',
  symbol: 'TKN',
  decimals: 18,
  logoUri: logo,
);

void main() {
  test('an .svg logo is drawn as SVG, whatever its query or case', () {
    expect(_token('https://x.io/eth.svg').hasSvgLogo, isTrue);
    expect(_token('https://x.io/ETH.SVG?v=2').hasSvgLogo, isTrue);
  });

  test('raster and missing logos are not', () {
    expect(_token('https://x.io/eth.png').hasSvgLogo, isFalse);
    expect(_token('https://x.io/svg/eth.png').hasSvgLogo, isFalse);
    expect(_token(null).hasSvgLogo, isFalse);
  });
}
