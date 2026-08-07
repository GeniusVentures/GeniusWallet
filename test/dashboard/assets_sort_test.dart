import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/dashboard/assets/assets_sort.dart';

/// The ordering and filtering rules behind `/assets`, exercised as pure
/// functions.
///
/// This file is the reason `assets_sort.dart` is Flutter-free. The rule it
/// encodes (D-1) is shared with plan 25-01's dashboard top-5, and a shared
/// rule that can only be checked by pumping a widget is a rule that silently
/// diverges between the two surfaces the day one of them is edited.
///
/// What this file does NOT cover: anything about how the rows LOOK, the
/// market-data fetch that fills `hasMarketData`/`price`, and the widget-level
/// wiring of the sort toggle. Those live in `assets_screen_test.dart` and on
/// the on-device walk.

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

  group('compareAssetsByValue - the unpriced tier (D-1)', () {
    test('an unpriced holding leads the whole list when descending', () {
      final rows = [
        _row('AAA', balance: 1, price: 500), // the largest priced row
        _row('UNL', balance: 42.5, hasMarketData: false),
        _row('BBB', balance: 1, price: 10),
      ];

      // Above the LARGEST priced row, not merely above the smallest.
      expect(_symbols(sortAssets(rows, ascending: false)), [
        'UNL',
        'AAA',
        'BBB',
      ]);
    });

    test('the same unpriced holding trails the whole list when ascending', () {
      final rows = [
        _row('AAA', balance: 1, price: 500),
        _row('UNL', balance: 42.5, hasMarketData: false),
        _row('BBB', balance: 1, price: 10),
      ];

      // Below the LARGEST priced row: ascending is the mirror of descending,
      // not the same list with the block pinned to the top. A block that
      // stayed put in both directions is what makes the toggle read as broken.
      expect(_symbols(sortAssets(rows, ascending: true)), [
        'BBB',
        'AAA',
        'UNL',
      ]);
    });

    test('a resolved price of 0 is still an unpriced holding', () {
      // hasMarketData is true but the quote is 0, so `balance * price` is 0
      // and the row would otherwise sink among the zero-value rows. It holds
      // a balance the app cannot price, which is the case the tier exists for.
      final rows = [
        _row('AAA', balance: 1, price: 500),
        _row('ZERO', balance: 7, price: 0),
      ];

      expect(_symbols(sortAssets(rows, ascending: false)), ['ZERO', 'AAA']);
    });

    test('two unpriced holdings order by balance, mirrored per direction', () {
      final rows = [
        _row('SMALL', balance: 1, hasMarketData: false),
        _row('BIG', balance: 999, hasMarketData: false),
        _row('AAA', balance: 1, price: 10),
      ];

      expect(_symbols(sortAssets(rows, ascending: false)), [
        'BIG',
        'SMALL',
        'AAA',
      ]);
      expect(_symbols(sortAssets(rows, ascending: true)), [
        'AAA',
        'SMALL',
        'BIG',
      ]);
    });

    test('a zero-balance row with no price is NOT an unpriced holding', () {
      // It owns nothing, so there is nothing the app failed to price. It ranks
      // as value 0 among the priced rows rather than being promoted to the top
      // of a funded wallet.
      final rows = [
        _row('AAA', balance: 1, price: 500),
        _row('NIL', balance: 0, hasMarketData: false),
      ];

      expect(sortAssets(rows, ascending: false)[1].symbol, 'NIL');
      expect(_symbols(sortAssets(rows, ascending: false)), ['AAA', 'NIL']);
      expect(_symbols(sortAssets(rows, ascending: true)), ['NIL', 'AAA']);
    });
  });

  group('compareAssetsByValue - GNUS is PINNED first (restored 2026-08-07)', () {
    // The regression these cases exist to catch is invisible on an all-zero
    // wallet. Phase 25 demoted GNUS from an absolute partition to a tie-break,
    // and because every priced row in a zero wallet ties at value 0, GNUS still
    // came out first and a walk could not see the change. Every case below is
    // therefore FUNDED, with values far enough apart that no accidental tie can
    // let a tie-break-only rule pass.

    test('GNUS leads a funded wallet even as the smallest holding', () {
      final rows = [
        _row('WBTC', balance: 0.5, price: 60000), // 30000
        _row('GNUS', balance: 100, price: 0.85), // 85, the SMALLEST
        _row('ETH', balance: 1, price: 3200), // 3200
      ];

      // Under the phase 25 tie-break reading this was WBTC, ETH, GNUS: GNUS
      // ranks last by value and never reaches a tie to win. A pin outranks
      // value outright.
      expect(_symbols(sortAssets(rows, ascending: false)), [
        'GNUS',
        'WBTC',
        'ETH',
      ]);
    });

    test('ascending keeps GNUS first and mirrors only what follows it', () {
      final rows = [
        _row('WBTC', balance: 0.5, price: 60000), // 30000
        _row('GNUS', balance: 100, price: 0.85), // 85
        _row('ETH', balance: 1, price: 3200), // 3200
      ];

      // The documented decision: a pinned row is pinned in both directions, and
      // the arrow reorders everything AROUND that fixed head. The rejected
      // alternative was mirroring GNUS to last when ascending, which would read
      // as the token teleporting rather than as a sort.
      expect(_symbols(sortAssets(rows, ascending: true)), [
        'GNUS',
        'ETH',
        'WBTC',
      ]);
    });

    test('the pin outranks the unpriced tier, in both directions', () {
      final rows = [
        _row('AAA', balance: 1, price: 500),
        _row('UNL', balance: 42.5, hasMarketData: false),
        _row('GNUS', balance: 100, price: 0.85), // 85
      ];

      // The accepted cost, asserted so it is a decision and not a surprise: the
      // unpriced holding is the row that needs attention, and it now sits one
      // place lower. The tier still leads everything that is not GNUS.
      expect(_symbols(sortAssets(rows, ascending: false)), [
        'GNUS',
        'UNL',
        'AAA',
      ]);
      // Ascending still sinks the tier. Only the pin refuses to move.
      expect(_symbols(sortAssets(rows, ascending: true)), [
        'GNUS',
        'AAA',
        'UNL',
      ]);
    });

    test('a GNUS balance of ZERO is still pinned above a funded wallet', () {
      // Held-none renders an ordinary $0.00 row at the top, beside the page's
      // `Buy GNUS` CTA, which is why it reads as an offer and not as a defect.
      // Making the pin conditional on balance > 0 was rejected: the row would
      // leap down the list the moment a balance hit zero.
      final rows = [
        _row('WBTC', balance: 0.5, price: 60000), // 30000
        _row('UNL', balance: 5, hasMarketData: false), // unpriced tier
        _row('GNUS', balance: 0, price: 0.85), // 0, and NOT unpriced
      ];

      expect(_symbols(sortAssets(rows, ascending: false)), [
        'GNUS',
        'UNL',
        'WBTC',
      ]);
    });

    test('a wallet holding no GNUS is ordered exactly as it was', () {
      // The pin ORDERS rows, it never invents one. Same input and same
      // expectation as the unpriced-tier case above, so if the pin ever leaked
      // a phantom row or disturbed a GNUS-free wallet, this fails.
      final rows = [
        _row('AAA', balance: 1, price: 500),
        _row('UNL', balance: 42.5, hasMarketData: false),
        _row('BBB', balance: 1, price: 10),
      ];

      expect(_symbols(sortAssets(rows, ascending: false)), [
        'UNL',
        'AAA',
        'BBB',
      ]);
      expect(_symbols(sortAssets(rows, ascending: true)), [
        'BBB',
        'AAA',
        'UNL',
      ]);
    });

    test('the pin matches the symbol case-insensitively', () {
      // Coin symbols reach the projection straight off the wallet model, so the
      // casing is whatever the chain handed over.
      final rows = [
        _row('AAA', balance: 1, price: 500),
        _row('gnus', balance: 1, price: 1),
      ];

      expect(_symbols(sortAssets(rows, ascending: false)), ['gnus', 'AAA']);
    });

    test('two GNUS rows still rank against each other by value', () {
      // A wallet may legitimately hold the same symbol on two networks. The pin
      // separates GNUS from everything else, never GNUS from itself, so the two
      // pinned rows fall through to the ordinary value ranking.
      final rows = [
        _row('AAA', balance: 1, price: 1000),
        _row('GNUS', balance: 1, price: 10),
        _row('GNUS', balance: 1, price: 500),
      ];

      final sorted = sortAssets(rows, ascending: false);
      expect(_symbols(sorted), ['GNUS', 'GNUS', 'AAA']);
      expect(sorted.map((r) => r.value).toList(), [500, 10, 1000]);
    });

    test('the pin does not cost totality on a funded wallet', () {
      // Same guarantee the all-zero case below relies on, re-checked with the
      // pin in play: `List.sort` is not stable, so a non-total order would let
      // rows twitch between rebuilds.
      final a = [
        _row('WBTC', balance: 0.5, price: 60000),
        _row('GNUS', balance: 100, price: 0.85),
        _row('UNL', balance: 5, hasMarketData: false),
        _row('ETH', balance: 1, price: 3200),
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
  });

  group('compareAssetsByValue - the tie-breaks are direction-independent', () {
    test('an all-zero wallet reads GNUS first then A to Z, both directions', () {
      // Jakub's real wallet. Every row ties at value 0, so the tie-breaks are
      // the ENTIRE ordering, and because they do not flip, the list is
      // identical in both directions. That is correct - nothing has value to
      // rank - and it is why tapping the toggle here changes the arrow and not
      // the order (on-device check W-4).
      final rows = [
        _row('USDC', balance: 0, price: 1),
        _row('ETH', balance: 0, price: 3200),
        _row('GNUS', balance: 0, price: 0.85),
        _row('AAVE', balance: 0, price: 90),
      ];

      const expected = ['GNUS', 'AAVE', 'ETH', 'USDC'];
      expect(_symbols(sortAssets(rows, ascending: false)), expected);
      expect(_symbols(sortAssets(rows, ascending: true)), expected);
    });

    test('symbol tie-break is case-insensitive', () {
      final rows = [
        _row('bbb', balance: 0, price: 1),
        _row('AAA', balance: 0, price: 1),
      ];

      expect(_symbols(sortAssets(rows, ascending: false)), ['AAA', 'bbb']);
    });
  });

  group('compareAssetsByValue - totality', () {
    test('two different input orders sort to the same output order', () {
      // Dart's `List.sort` is NOT stable (the trap `coins_screen.dart:238`
      // documents). Without total tie-breaks an all-zero wallet would reorder
      // itself between rebuilds, which on device looks like rows twitching for
      // no reason.
      final a = [
        _row('USDC', balance: 0, price: 1),
        _row('ETH', balance: 0, price: 3200),
        _row('GNUS', balance: 0, price: 0.85),
        _row('AAVE', balance: 0, price: 90),
        _row('UNL', balance: 5, hasMarketData: false),
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
