import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/dashboard/assets/assets_sort.dart';

/// The holdings ordering and filtering rules, exercised as pure functions.

AssetRowData _row(
  String symbol, {
  String? name,
  double balance = 0,
  double price = 0,
  bool? hasMarketData,
}) => AssetRowData(
  name: name ?? symbol,
  symbol: symbol,
  balance: balance,
  price: price,
  // Default: a row is "priced" whenever a price was supplied. Cases that need
  // the two apart (a listed coin quoting 0, a held coin the feed never
  // covered) pass the flag explicitly.
  hasMarketData: hasMarketData ?? true,
);

List<String> _symbols(List<AssetRowData> rows) =>
    rows.map((r) => r.symbol).toList();

void main() {
  group('compareAssetsByValue - priced rows', () {
    test('descending puts the largest value first', () {
      final rows = [
        _row('AAA', balance: 1, price: 10), // 10
        _row('BBB', balance: 1, price: 500), // 500
        _row('CCC', balance: 2, price: 60), // 120
      ];

      expect(_symbols(sortAssets(rows, ascending: false)), [
        'BBB',
        'CCC',
        'AAA',
      ]);
    });

    test('ascending puts the smallest value first', () {
      final rows = [
        _row('AAA', balance: 1, price: 10), // 10
        _row('BBB', balance: 1, price: 500), // 500
        _row('CCC', balance: 2, price: 60), // 120
      ];

      expect(_symbols(sortAssets(rows, ascending: true)), [
        'AAA',
        'CCC',
        'BBB',
      ]);
    });
  });

  group('compareAssetsByValue - unpriced holdings', () {
    test('an unpriced holding sorts after every priced one', () {
      final rows = [
        _row('UNL', balance: 42.5, hasMarketData: false),
        _row('BBB', balance: 1, price: 10),
        _row('AAA', balance: 1, price: 500),
      ];

      expect(_symbols(sortAssets(rows, ascending: false)), [
        'AAA',
        'BBB',
        'UNL',
      ]);
      expect(_symbols(sortAssets(rows, ascending: true)), [
        'UNL',
        'BBB',
        'AAA',
      ]);
    });

    test('a resolved price of 0 is still an unpriced holding', () {
      final rows = [
        _row('ZERO', balance: 7, price: 0),
        _row('AAA', balance: 1, price: 500),
      ];

      expect(_symbols(sortAssets(rows, ascending: false)), ['AAA', 'ZERO']);
    });

    test('unpriced holdings order by balance, then by symbol', () {
      final rows = [
        _row('SMALL', balance: 1, hasMarketData: false),
        _row('BIG', balance: 999, hasMarketData: false),
        _row('BBB', balance: 1, hasMarketData: false),
        _row('AAA', balance: 1, price: 10),
      ];

      expect(_symbols(sortAssets(rows, ascending: false)), [
        'AAA',
        'BIG',
        'BBB',
        'SMALL',
      ]);
    });

    test('rows holding nothing come after every holding', () {
      final rows = [
        _row('NIL', balance: 0, hasMarketData: false),
        _row('ETH', balance: 0, price: 3200),
        _row('UNL', balance: 5, hasMarketData: false),
        _row('AAA', balance: 1, price: 500),
      ];

      expect(_symbols(sortAssets(rows, ascending: false)), [
        'AAA',
        'UNL',
        'ETH',
        'NIL',
      ]);
    });
  });

  group('compareAssetsByValue - GNUS ranks by its own value', () {
    test('a small GNUS holding sits below larger holdings', () {
      final rows = [
        _row('WBTC', balance: 0.5, price: 60000), // 30000
        _row('GNUS', balance: 100, price: 0.85), // 85
        _row('ETH', balance: 1, price: 3200), // 3200
      ];

      expect(_symbols(sortAssets(rows, ascending: false)), [
        'WBTC',
        'ETH',
        'GNUS',
      ]);
    });

    test('a zero GNUS balance in a funded wallet goes to the bottom', () {
      final rows = [
        _row('GNUS', balance: 0, price: 0.85),
        _row('UNL', balance: 5, hasMarketData: false),
        _row('WBTC', balance: 0.5, price: 60000),
      ];

      expect(_symbols(sortAssets(rows, ascending: false)), [
        'WBTC',
        'UNL',
        'GNUS',
      ]);
    });
  });

  group('orderAssets - a wallet holding nothing', () {
    test('shows only the GNUS row', () {
      final rows = [
        _row('USDC', balance: 0, price: 1),
        _row('ETH', balance: 0, price: 3200),
        _row('gnus', balance: 0, price: 0.85),
        _row('AAVE', balance: 0, hasMarketData: false),
      ];

      for (final ascending in [true, false]) {
        expect(_symbols(sortAssets(rows, ascending: ascending)), ['gnus']);
      }
    });

    test('keeps every GNUS row, one per network', () {
      final rows = [
        _row('ETH', balance: 0, price: 3200),
        _row('GNUS', name: 'on Base', balance: 0, price: 0.85),
        _row('GNUS', name: 'on Polygon', balance: 0, price: 0.85),
      ];

      expect(_symbols(sortAssets(rows, ascending: false)), ['GNUS', 'GNUS']);
    });

    test('lists every row when there is no GNUS row to fall back to', () {
      final rows = [
        _row('USDC', balance: 0, price: 1),
        _row('ETH', balance: 0, price: 3200),
      ];

      expect(_symbols(sortAssets(rows, ascending: false)), ['ETH', 'USDC']);
    });

    test('an empty wallet stays empty', () {
      expect(sortAssets(const [], ascending: false), isEmpty);
    });

    test('any holding at all lists every row again', () {
      final rows = [
        _row('GNUS', balance: 0, price: 0.85),
        _row('ETH', balance: 0, price: 3200),
        _row('UNL', balance: 1, hasMarketData: false),
      ];

      expect(_symbols(sortAssets(rows, ascending: false)), [
        'UNL',
        'ETH',
        'GNUS',
      ]);
    });
  });

  group('compareAssetsByValue - totality', () {
    test('two different input orders sort to the same output order', () {
      // `List.sort` is not stable, so without total tie-breaks equal rows
      // would reorder themselves between rebuilds.
      final a = [
        _row('USDC', balance: 0, price: 1),
        _row('ETH', balance: 1, price: 3200),
        _row('GNUS', balance: 0, price: 0.85),
        _row('AAVE', balance: 0, price: 90),
        _row('UNL', balance: 5, hasMarketData: false),
        _row('BBB', balance: 5, hasMarketData: false),
      ];
      final b = a.reversed.toList();

      for (final ascending in [true, false]) {
        expect(
          _symbols(sortAssets(a, ascending: ascending)),
          _symbols(sortAssets(b, ascending: ascending)),
          reason: 'ascending=$ascending must not depend on input order',
        );
      }
    });

    test('symbol tie-break is case-insensitive and never flips', () {
      final rows = [
        _row('bbb', balance: 1, price: 1),
        _row('AAA', balance: 1, price: 1),
      ];

      expect(_symbols(sortAssets(rows, ascending: false)), ['AAA', 'bbb']);
      expect(_symbols(sortAssets(rows, ascending: true)), ['AAA', 'bbb']);
    });

    test('sortAssets does not mutate its argument', () {
      final rows = [
        _row('AAA', balance: 1, price: 10),
        _row('BBB', balance: 1, price: 500),
      ];
      final before = _symbols(rows);

      sortAssets(rows, ascending: false);

      expect(_symbols(rows), before);
    });
  });

  group('matchesAssetQuery', () {
    final row = _row('GNUS', name: 'GeniusAI', balance: 1, price: 1);

    test('an empty or whitespace query matches everything', () {
      expect(matchesAssetQuery('', row), isTrue);
      expect(matchesAssetQuery('   ', row), isTrue);
    });

    test('matches on name, case-insensitively', () {
      expect(matchesAssetQuery('genius', row), isTrue);
      expect(matchesAssetQuery('GENIUS', row), isTrue);
      expect(matchesAssetQuery('iusA', row), isTrue);
    });

    test('matches on symbol, case-insensitively', () {
      expect(matchesAssetQuery('gnus', row), isTrue);
      expect(matchesAssetQuery('NU', row), isTrue);
    });

    test('a query matching neither name nor symbol yields nothing', () {
      final rows = [row, _row('ETH', name: 'Ethereum')];

      expect(rows.where((r) => matchesAssetQuery('zzz', r)), isEmpty);
    });

    test('the query is trimmed before matching', () {
      expect(matchesAssetQuery('  gnus  ', row), isTrue);
    });
  });
}
