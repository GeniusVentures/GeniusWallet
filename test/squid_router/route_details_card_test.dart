import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/squid_router/models/squid_token_info.dart';
import 'package:genius_wallet/squid_router/route_details_card.dart';
import 'package:genius_wallet/squid_router/squid_token_service.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// Criterion 1's automated half (08-CONTEXT D-18b / D-08): a re-skin must not
/// disturb the route/fee/slippage figures `RouteDetailsCard` prints. The card
/// is always fed `mockSquidRoute` — `SquidTokenService.getRoute()` returns
/// that hardcoded constant regardless of input (D-18b) — so this test asserts
/// against the REAL constant the app uses, not a local copy, and never
/// asserts that the quote varies by token pair or amount.

SquidTokenInfo _token(String symbol) => SquidTokenInfo(
  chainId: 1,
  address: '0x0000000000000000000000000000000000000000',
  name: symbol,
  symbol: symbol,
  decimals: 18,
  crosschain: false,
  commonKey: symbol.toLowerCase(),
  logoURI: 'https://example.com/$symbol.png',
  coingeckoId: symbol.toLowerCase(),
);

Widget _host(Widget child, {GWColors? gw}) => MaterialApp(
  theme: ThemeData(extensions: [gw ?? GWColors.dark()]),
  home: Scaffold(body: child),
);

void main() {
  testWidgets('RouteDetailsCard prints the real mockSquidRoute figures', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        RouteDetailsCard(
          route: mockSquidRoute,
          fromAmount: '1',
          toAmount: '0.995',
          fromToken: _token('ETH'),
          toToken: _token('USDT'),
          slippage: '0.5',
        ),
      ),
    );

    // Row labels.
    expect(find.text('Pricing'), findsOneWidget);
    expect(find.text('Slippage'), findsOneWidget);
    expect(find.text('Price Impact'), findsOneWidget);
    expect(find.text('Fees'), findsOneWidget);

    // The four derived strings — golden values frozen from develop.
    expect(find.text('1 ETH ~ 0.995 USDT'), findsOneWidget);
    expect(find.text('0.5'), findsOneWidget);
    expect(find.text('0.51%'), findsOneWidget);
    expect(find.text('\$0.30'), findsOneWidget);
  });
}
