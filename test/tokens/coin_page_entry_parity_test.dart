// The parity gate quick task 260731-hsb owes: a source-scanning census that
// fails on a fourth /token-info push site (or one passing a bare map), plus
// the widget/unit behaviour that makes the census worth having - one payload
// type, the origin label, wallet-context rows that only render when the
// caller genuinely knows them, and the loading/failed/uncovered split that
// stops a rate limit from being printed as "not covered by our market data
// provider" (Findings 3).
//
// Group 1's tree walk is modelled structurally on
// `test/components/drawer_padding_invariant_test.dart`: dart:io reads, a
// hand-rolled call-region extractor that balances parens across line
// breaks, no widget pumping, no fixture directory.
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/tokens/token_info_args.dart';
import 'package:genius_wallet/tokens/token_info_screen.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

// Built from a joined constant rather than written out inline, so this
// file's own source can never textually match the scan below by accident -
// belt-and-suspenders: the scan only ever walks `lib/`, and this file lives
// in `test/`, but the plan asks for the defensive construction regardless.
const String _tokenInfoSegment = 'token-info';
const String _tokenInfoPath = '/$_tokenInfoSegment';

/// Reads [path] and strips full-line comments - the same approach
/// `drawer_padding_invariant_test.dart`'s `_strippedSource` uses.
String _strippedSource(String path) {
  final lines = File(path).readAsStringSync().split('\n');
  return lines.where((line) => !line.trim().startsWith('//')).join('\n');
}

/// Every `.push(...)` call region in [content] whose first string argument
/// is the token-info path, each as its own substring from `.push(` to the
/// matching closing paren - so a multi-line call is captured whole and a
/// per-call check never bleeds into a neighbouring call.
List<String> _tokenInfoPushRegions(String content) {
  final pattern = RegExp(r'\.push\(');
  final regions = <String>[];
  for (final match in pattern.allMatches(content)) {
    final openParenIndex = match.end - 1;
    var depth = 1;
    var i = openParenIndex + 1;
    while (i < content.length && depth > 0) {
      if (content[i] == '(') {
        depth++;
      } else if (content[i] == ')') {
        depth--;
      }
      i++;
    }
    final region = content.substring(match.start, i);
    if (region.contains("'$_tokenInfoPath'")) {
      regions.add(region);
    }
  }
  return regions;
}

/// Every `/token-info` push call region across `lib/`, keyed by the file it
/// came from. `global_swap_fab_host.dart` names the same path string in a
/// hidden-path SET (no `.push(` anywhere near it) and `router.dart` only
/// ever DEFINES the route (`path: '/token-info'`, never `.push(`) - neither
/// is a push site, so neither is discovered here.
Map<String, List<String>> _discoverTokenInfoPushSites() {
  final discovered = <String, List<String>>{};
  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) {
      continue;
    }
    final relativePath = entity.path.replaceAll('\\', '/');
    final content = _strippedSource(relativePath);
    final regions = _tokenInfoPushRegions(content);
    if (regions.isNotEmpty) {
      discovered[relativePath] = regions;
    }
  }
  return discovered;
}

/// `WalletDetailsCubit` takes a `GeniusApi` this screen never touches in any
/// path this file exercises - same four-line stand-in every other test in
/// this directory already uses.
class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

CoinGeckoMarketData _usdc({double price = 1.0}) =>
    CoinGeckoMarketData.fromJson({
      'id': 'usd-coin',
      'symbol': 'usdc',
      'name': 'USD Coin',
      'current_price': price,
    });

Widget _host({
  required TokenInfoArgs args,
  bool isGnusWalletConnected = false,
  Future<Map<String, CoinGeckoMarketData?>> Function(List<String>)?
  resolveMarketData,
}) => BlocProvider(
  create: (_) => WalletDetailsCubit(
    geniusApi: _UnusedApi(),
    networkTokensProvider: NetworkTokensProvider(),
  ),
  child: MaterialApp(
    theme: ThemeData(extensions: [GWColors.dark()]),
    home: Builder(
      builder: (context) => TokenInfoScreen(
        walletDetailsCubit: context.read<WalletDetailsCubit>(),
        args: args,
        isGnusWalletConnected: isGnusWalletConnected,
        resolveMarketData: resolveMarketData,
      ),
    ),
  ),
);

void main() {
  group('Coin-page entry parity census (260731-hsb)', () {
    test('exactly three /token-info push call sites in lib/, every one passing '
        'a TokenInfoArgs', () {
      final discovered = _discoverTokenInfoPushSites();
      final allRegions = discovered.values.expand((r) => r).toList();

      expect(
        allRegions.length,
        3,
        reason:
            'Found ${allRegions.length} /token-info push call site(s) in '
            'lib/ (files: ${discovered.keys.toList()}) - a new coin-page '
            'entry point was added. It must pass TokenInfoArgs so the '
            'route stays the only assembler, and this count (3) is the '
            'census to update once that holds.',
      );

      final extraTypePattern = RegExp(r'extra\s*:\s*(\w+)');
      for (final entry in discovered.entries) {
        for (final region in entry.value) {
          final match = extraTypePattern.firstMatch(region);
          expect(
            match,
            isNotNull,
            reason:
                '${entry.key}: a /token-info push has no extra: '
                'argument at all',
          );
          expect(
            match!.group(1),
            'TokenInfoArgs',
            reason:
                '${entry.key}: a /token-info push passes '
                '${match.group(1)} as extra, not TokenInfoArgs - every '
                'call site must build the typed payload so the route '
                'stays the only assembler',
          );
        }
      }
    });

    test('no file in lib/ puts a connection flag key inside a /token-info '
        'extra', () {
      final discovered = _discoverTokenInfoPushSites();
      final flagPattern = RegExp('isGnusWalletConnected');
      for (final entry in discovered.entries) {
        for (final region in entry.value) {
          expect(
            flagPattern.hasMatch(region),
            isFalse,
            reason:
                '${entry.key}: a /token-info push still carries '
                'isGnusWalletConnected in its extra - router.dart derives '
                'this flag now (a BehaviorSubject.seeded read), so no '
                'call site should carry it any more',
          );
        }
      }
    });
  });

  group('TokenInfoArgs.fromExtra', () {
    test('an already-typed TokenInfoArgs round-trips unchanged', () {
      const args = TokenInfoArgs(coinGeckoId: 'bitcoin', originLabel: 'ASSETS');
      expect(identical(TokenInfoArgs.fromExtra(args), args), isTrue);
    });

    test('null becomes the const empty payload, MARKETS default', () {
      final args = TokenInfoArgs.fromExtra(null);
      expect(args.marketData, isNull);
      expect(args.coinGeckoId, isNull);
      expect(args.walletCoin, isNull);
      expect(args.originLabel, 'MARKETS');
    });

    test('the legacy map shape carries its marketData through', () {
      final data = _usdc();
      final args = TokenInfoArgs.fromExtra({
        'marketData': data,
        // Deliberately still present in the legacy shape (what an old deep
        // link might carry) - fromExtra must not choke on it, and must not
        // surface it on the returned TokenInfoArgs (there is no field for
        // it any more).
        'isGnusWalletConnected': true,
      });
      expect(args.marketData, data);
      expect(args.originLabel, 'MARKETS');
    });

    test('a serialised (JSON map) marketData deep link still decodes', () {
      final args = TokenInfoArgs.fromExtra({
        'marketData': {'id': 'usd-coin', 'symbol': 'usdc', 'name': 'USD Coin'},
      });
      expect(args.marketData?.id, 'usd-coin');
    });

    test('an unrecognised extra returns the const empty payload', () {
      final args = TokenInfoArgs.fromExtra('garbage');
      expect(args.marketData, isNull);
      expect(args.coinGeckoId, isNull);
    });
  });

  group('TokenInfoScreen - origin label and wallet-context rows', () {
    testWidgets('originLabel renders on the back link; default is MARKETS', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400 * 2, 1000 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _host(
          args: TokenInfoArgs(marketData: _usdc(), originLabel: 'ASSETS'),
        ),
      );
      await tester.pump();

      expect(find.text('ASSETS'), findsOneWidget);
      expect(find.text('MARKETS'), findsNothing);
    });

    testWidgets(
      'default originLabel renders MARKETS - unchanged from before this '
      'plan',
      (tester) async {
        tester.view.physicalSize = const Size(1400 * 2, 1000 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          _host(args: TokenInfoArgs(marketData: _usdc())),
        );
        await tester.pump();

        expect(find.text('MARKETS'), findsOneWidget);
      },
    );

    testWidgets('a null walletCoin renders no Address or Network row', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400 * 2, 1000 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_host(args: TokenInfoArgs(marketData: _usdc())));
      await tester.pump();

      // T-hsb-02: this is the row that used to print the WALLET's address
      // for a token opened from Markets - a fact about a different chain
      // entirely. Null walletCoin/network (both Markets surfaces) must drop
      // both rows rather than lie with them.
      expect(find.text('Address'), findsNothing);
      expect(find.text('Network'), findsNothing);
    });

    testWidgets('a walletCoin with an address renders both rows', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400 * 2, 1000 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _host(
          args: TokenInfoArgs(
            marketData: _usdc(),
            walletCoin: const Coin(
              address: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
            ),
            network: 'Ethereum',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Address'), findsOneWidget);
      expect(find.text('Network'), findsOneWidget);
    });
  });

  group('TokenInfoScreen - resolves its own market data', () {
    testWidgets(
      'no marketData + a coinGeckoId: loading, then the resolved price',
      (tester) async {
        tester.view.physicalSize = const Size(1400 * 2, 1000 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);

        final completer = Completer<Map<String, CoinGeckoMarketData?>>();
        await tester.pumpWidget(
          _host(
            args: const TokenInfoArgs(coinGeckoId: 'usd-coin', symbol: 'USDC'),
            resolveMarketData: (_) => completer.future,
          ),
        );
        await tester.pump();

        // Still asking - not "not covered". The bug this plan fixes is
        // exactly this state being rendered as the terminal one.
        expect(find.byType(Loading), findsOneWidget);
        expect(find.text('No market data'), findsNothing);

        completer.complete({'usdc': _usdc(price: 1.0)});
        await tester.pump();
        await tester.pump();

        expect(find.byType(Loading), findsNothing);
        // The title comes from the resolved marketData's own name - direct
        // proof the fetched record, not a stale fallback, is on screen.
        expect(find.text('USD Coin'), findsOneWidget);
      },
    );

    testWidgets(
      'a resolver that throws shows Retry, not the terminal "not covered" '
      'wording; tapping it re-fetches and renders on success',
      (tester) async {
        tester.view.physicalSize = const Size(1400 * 2, 1000 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);

        var callCount = 0;
        await tester.pumpWidget(
          _host(
            args: const TokenInfoArgs(coinGeckoId: 'usd-coin', symbol: 'USDC'),
            resolveMarketData: (_) async {
              callCount++;
              if (callCount == 1) {
                throw Exception('rate limited');
              }
              return {'usdc': _usdc(price: 2.0)};
            },
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(callCount, 1);
        // T-hsb-03: the exact wording this plan makes untrue for a transient
        // failure - it must not appear here.
        expect(
          find.text(
            'This token is not covered by our market data provider, so '
            'there is no price, chart or market statistics for it. '
            'Everything else on this page still works.',
          ),
          findsNothing,
        );
        expect(find.widgetWithText(GWButton, 'Retry'), findsOneWidget);

        await tester.tap(find.widgetWithText(GWButton, 'Retry'));
        await tester.pump();
        await tester.pump();

        // Two calls, not one re-render of the first - Retry actually asked
        // again rather than replaying stale state.
        expect(callCount, 2);
        expect(find.widgetWithText(GWButton, 'Retry'), findsNothing);
        expect(find.text('USD Coin'), findsOneWidget);
      },
    );

    testWidgets(
      'no marketData and no coinGeckoId: the existing "No market data" '
      'card, immediately, with no fetch',
      (tester) async {
        tester.view.physicalSize = const Size(1400 * 2, 1000 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);

        var resolverCalls = 0;
        await tester.pumpWidget(
          _host(
            args: const TokenInfoArgs(),
            resolveMarketData: (_) async {
              resolverCalls++;
              return {};
            },
          ),
        );
        await tester.pump();

        expect(find.text('No market data'), findsOneWidget);
        expect(
          resolverCalls,
          0,
          reason:
              'a coin with no id and no warm-start data has nothing to '
              'ask for - the resolver must never be called',
        );
      },
    );
  });
}
