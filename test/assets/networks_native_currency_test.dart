// A network's `symbol` is the CHAIN key; its native currency is a separate
// fact. Base is where the two differ — the chain is "base", the coin you spend
// is ETH — and conflating them printed a coin called BASE priced at $0.
//
// These cases read the shipped asset, not a fixture: the defect was in the
// data, so a fixture would have proved nothing.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';

Map<String, dynamic> _network(List<dynamic> all, int chainId) =>
    all.cast<Map<String, dynamic>>().firstWhere(
      (n) => n['chainId'] == chainId,
      orElse: () => throw StateError('no network with chainId $chainId'),
    );

void main() {
  final networks =
      jsonDecode(File('assets/json/networks/networks.json').readAsStringSync())
          as List<dynamic>;

  test('Base spends ETH, not a coin named after the chain', () {
    final base = _network(networks, 8453);

    // The ticker the holdings row shows and the price lookup keys on.
    expect(base['nativeSymbol'], 'eth');
    // CoinGecko has no asset under the id "base" for Base's gas coin; asking
    // for one is why the row priced at $0.
    expect(base['coinGeckoId'], 'ethereum');
  });

  test('the chain key stays "base" so receipts reach basescan', () {
    final base = _network(networks, 8453);

    // Renaming this to "eth" would send every Base receipt to etherscan,
    // where the hash does not resolve. The explorer map is keyed on it.
    expect(base['symbol'], 'base');
    expect(
      getExplorerUrl(base['symbol'] as String, '0xabc'),
      'https://basescan.org/tx/0xabc',
    );
  });

  test('every network declares a native currency and a price id', () {
    for (final entry in networks.cast<Map<String, dynamic>>()) {
      final name = entry['name'];
      // `nativeSymbol` is optional and falls back to `symbol`; where it is
      // absent the two must genuinely be the same coin.
      expect(
        entry['coinGeckoId'],
        isNotNull,
        reason: '$name has no coinGeckoId, so it can never be priced',
      );
      expect(
        (entry['nativeSymbol'] ?? entry['symbol']),
        isNotNull,
        reason: '$name has no spendable currency ticker',
      );
    }
  });
}
