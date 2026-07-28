import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/squid_router/models/squid_balance.dart';
import 'package:genius_wallet/squid_router/models/squid_token_info.dart';
import 'package:genius_wallet/squid_router/token_selector_drawer.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// The empty state Braian asked for alongside the pay-side holdings filter
/// (08-07 walk, 2026-07-27).
///
/// Filtering the pay side to holdings makes an EMPTY picker an ordinary state —
/// a new wallet, or one whose only token sits on another network. Before this,
/// an empty list fell through to the search empty-state and read
/// `No tokens match ""`, which describes the wrong thing entirely.
///
/// These cases pin the distinction between the two empties, because they are
/// easy to collapse back into one during a refactor.

SquidTokenInfo _token(String symbol, {String? balance}) => SquidTokenInfo(
  chainId: 1,
  address: '0x${symbol.toLowerCase()}',
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
          address: '0x${symbol.toLowerCase()}',
          decimals: 18,
          chainId: '1',
        ),
);

Widget _host(Widget child, {GWColors? gw}) => MaterialApp(
  theme: ThemeData(extensions: [gw ?? GWColors.dark()]),
  home: Scaffold(body: child),
);

void main() {
  testWidgets('an empty pay-side list shows the holdings empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        TokenSelectorDrawer(
          tokens: const [],
          onTokenSelected: (_) {},
          emptyTitle: 'No tokens to swap',
          emptyMessage: 'This wallet holds no tokens with a balance.',
        ),
      ),
    );

    expect(find.text('No tokens to swap'), findsOneWidget);
    expect(
      find.text('This wallet holds no tokens with a balance.'),
      findsOneWidget,
    );
    // The search empty-state must NOT be what answers here.
    expect(find.textContaining('No tokens match'), findsNothing);
  });

  testWidgets(
    'the search field is suppressed when there is nothing to search',
    (tester) async {
      await tester.pumpWidget(
        _host(
          TokenSelectorDrawer(
            tokens: const [],
            onTokenSelected: (_) {},
            emptyTitle: 'No tokens to swap',
          ),
        ),
      );

      // A field whose every query returns the same empty state is a dead end.
      expect(find.byType(TextField), findsNothing);
    },
  );

  testWidgets('a caller passing no copy still gets a sane default', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(TokenSelectorDrawer(tokens: const [], onTokenSelected: (_) {})),
    );

    expect(find.text('No tokens available'), findsOneWidget);
  });

  testWidgets('a non-empty list renders rows and the search field, not the '
      'empty state', (tester) async {
    await tester.pumpWidget(
      _host(
        TokenSelectorDrawer(
          tokens: [_token('ETH', balance: '1000000000000000000')],
          onTokenSelected: (_) {},
          emptyTitle: 'No tokens to swap',
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('No tokens to swap'), findsNothing);
    expect(find.text('ETH'), findsWidgets);
  });

  testWidgets('a query matching nothing shows the SEARCH empty state, not the '
      'holdings one', (tester) async {
    await tester.pumpWidget(
      _host(
        TokenSelectorDrawer(
          tokens: [_token('ETH', balance: '1000000000000000000')],
          onTokenSelected: (_) {},
          emptyTitle: 'No tokens to swap',
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pump();

    expect(find.textContaining('No tokens match'), findsOneWidget);
    expect(find.text('No tokens to swap'), findsNothing);
  });
}
