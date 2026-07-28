import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/squid_router/models/squid_balance.dart';
import 'package:genius_wallet/squid_router/models/squid_token_info.dart';
import 'package:genius_wallet/squid_router/swap_preselection.dart';

/// Pins the coin-page Swap button's landing behaviour, asked for by Braian at
/// the 08-07 walk: *"it should go to swap with the coin selected already."*
///
/// The load-bearing case is the pay/receive split. It is not cosmetic: the pay
/// side is filtered to holdings, so seating an unheld coin there would deliver
/// a form whose CTA can only ever read "Insufficient balance".

SquidTokenInfo _token(
  String symbol, {
  String? balance,
  int chainId = 1,
}) => SquidTokenInfo(
  chainId: chainId,
  address: '0x${symbol.toLowerCase()}$chainId',
  name: symbol,
  symbol: symbol,
  decimals: 18,
  crosschain: true,
  commonKey: symbol,
  logoURI: '',
  coingeckoId: symbol.toLowerCase(),
  balance: balance == null
      ? null
      : SquidBalance(
          balance: balance,
          symbol: symbol,
          address: '0x${symbol.toLowerCase()}$chainId',
          decimals: 18,
          chainId: '$chainId',
        ),
);

void main() {
  group('nothing to seat', () {
    test('a null symbol seats nothing', () {
      expect(
        resolvePreselection(tokens: [_token('ETH')], symbol: null),
        isNull,
      );
    });

    test('an empty or whitespace symbol seats nothing', () {
      expect(resolvePreselection(tokens: [_token('ETH')], symbol: ''), isNull);
      expect(resolvePreselection(tokens: [_token('ETH')], symbol: '  '), isNull);
    });

    test('an unmatched symbol seats NOTHING rather than a neighbour', () {
      // GNUS has no entry in the mock catalogue. Seating a near-miss would be
      // worse than an empty form.
      final result = resolvePreselection(
        tokens: [_token('ETH'), _token('USDT')],
        symbol: 'GNUS',
      );
      expect(result, isNull);
    });

    test('an empty catalogue seats nothing', () {
      expect(resolvePreselection(tokens: [], symbol: 'ETH'), isNull);
    });
  });

  group('the pay / receive split', () {
    test('a HELD coin seats on the pay side — the user is spending it', () {
      final result = resolvePreselection(
        tokens: [_token('ETH', balance: '1000000000000000000')],
        symbol: 'ETH',
      );
      expect(result, isNotNull);
      expect(result!.side, PreselectSide.pay);
      expect(result.token.symbol, 'ETH');
    });

    test('an UNHELD coin seats on the receive side — acquiring it', () {
      // Seating this on the pay side would reintroduce exactly what the
      // holdings filter removes.
      final result = resolvePreselection(
        tokens: [_token('WFTM')],
        symbol: 'WFTM',
      );
      expect(result!.side, PreselectSide.receive);
    });

    test('a ZERO balance counts as unheld, not held', () {
      final result = resolvePreselection(
        tokens: [_token('DAI', balance: '0')],
        symbol: 'DAI',
      );
      expect(result!.side, PreselectSide.receive);
    });

    test('dust still counts as held', () {
      // 1 wei is spendable, and the picker already renders it as <0.000001.
      final result = resolvePreselection(
        tokens: [_token('ETH', balance: '1')],
        symbol: 'ETH',
      );
      expect(result!.side, PreselectSide.pay);
    });
  });

  group('choosing between chains', () {
    test('the requested chain wins when the catalogue has it', () {
      final result = resolvePreselection(
        tokens: [
          _token('ETH', chainId: 1, balance: '5'),
          _token('ETH', chainId: 137),
        ],
        symbol: 'ETH',
        chainId: 137,
      );
      expect(result!.token.chainId, 137);
      // …and the side still follows THAT token's balance, not another chain's.
      expect(result.side, PreselectSide.receive);
    });

    test('an unknown chain hint falls back rather than seating nothing', () {
      // A coin page for a chain the Squid catalogue does not carry should
      // still open on the right symbol.
      final result = resolvePreselection(
        tokens: [_token('ETH', chainId: 1, balance: '5')],
        symbol: 'ETH',
        chainId: 42161,
      );
      expect(result!.token.chainId, 1);
      expect(result.side, PreselectSide.pay);
    });

    test('with no chain hint, a HELD chain is preferred over an unheld one', () {
      final result = resolvePreselection(
        tokens: [
          _token('USDT', chainId: 1), // listed first, but not held
          _token('USDT', chainId: 137, balance: '500'),
        ],
        symbol: 'USDT',
      );
      expect(result!.token.chainId, 137);
      expect(result.side, PreselectSide.pay);
    });

    test('symbol matching is case-insensitive', () {
      final result = resolvePreselection(
        tokens: [_token('ETH', balance: '5')],
        symbol: 'eth',
      );
      expect(result, isNotNull);
      expect(result!.side, PreselectSide.pay);
    });
  });
}
