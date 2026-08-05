// The ONE check the token picker's list rule owes.
//
// Jakub picked DAI, reopened the picker, and DAI was not in the list - so the
// `selectedToken` that sketch 068-A wired through could never render, because
// the row it marks had been filtered out one layer up.
//
// Both call sites excluded THIS side's own token as well as the other side's.
// That reads as reasonable ("you already picked it") and is exactly wrong for a
// picker whose job is to show you what you picked. Every other picker in the app
// - Select Network, Your Accounts, SDK Accounts - shows the active row.
//
// So the first test below is the regression, and it is the one that matters.
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/squid_router/models/squid_token_info.dart';
import 'package:genius_wallet/squid_router/swap_screen.dart';

SquidTokenInfo _token(String symbol, String address, {int chainId = 1}) =>
    SquidTokenInfo(
      chainId: chainId,
      address: address,
      name: symbol,
      symbol: symbol,
      decimals: 18,
      crosschain: true,
      commonKey: symbol,
      logoURI: '',
      coingeckoId: symbol,
    );

void main() {
  final dai = _token('DAI', '0xDAI');
  final usdc = _token('USDC', '0xUSDC');
  final eth = _token('ETH', '0xETH');
  final all = [dai, usdc, eth];

  group('tokensForSide', () {
    test('KEEPS this side\'s own token so it can render as selected', () {
      // fromToken = DAI, toToken = USDC. The You Pay list must still offer DAI.
      final forPay = tokensForSide(all, usdc);
      expect(forPay, contains(dai));
    });

    test('hides the other side, so one token cannot be both legs', () {
      expect(tokensForSide(all, usdc), isNot(contains(usdc)));
      expect(tokensForSide(all, dai), isNot(contains(dai)));
    });

    test('with no other side chosen, nothing is hidden', () {
      expect(tokensForSide(all, null).length, all.length);
    });
  });

  group('sameAs', () {
    test('address alone is not identity - the list is cross-chain', () {
      // The same address on two chains is two different tokens. Dropping the
      // chainId half would hide a token from a chain the user never touched.
      final onEthereum = _token('USDC', '0xSAME', chainId: 1);
      final onPolygon = _token('USDC', '0xSAME', chainId: 137);
      expect(onEthereum.sameAs(onPolygon), isFalse);
      expect(tokensForSide([onEthereum, onPolygon], onPolygon), [onEthereum]);
    });

    test('address case is not identity - checksummed vs lowercase', () {
      expect(_token('DAI', '0xAbCd').sameAs(_token('DAI', '0xabcd')), isTrue);
    });

    test('null is never the same as anything', () {
      expect(dai.sameAs(null), isFalse);
    });
  });
}
