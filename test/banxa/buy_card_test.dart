import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_wallet/banxa/banxa_api_services.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/buy_gnus_cubit.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/screens/banxa_buy_screen.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

import 'fake_banxa_api.dart';
import 'fixtures.dart';

const _address = '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed';

final _card = PaymentMethod(
  id: 'card',
  name: 'Card',
  minimum: 20,
  maximum: 15000,
);
final _usd = FiatCurrency(
  code: 'USD',
  name: 'US Dollar',
  symbol: r'$',
  supportedPaymentMethods: [_card],
);
final _eur = FiatCurrency(
  code: 'EUR',
  name: 'Euro',
  symbol: '€',
  supportedPaymentMethods: [
    PaymentMethod(id: 'sepa', name: 'SEPA', minimum: 10, maximum: 5000),
    PaymentMethod(id: 'eurcard', name: 'Card', minimum: 10, maximum: 5000),
  ],
);
final _gnus = CryptoCurrency(
  code: 'GNUS',
  name: 'GNUS',
  blockchains: [
    Blockchain(
      id: 'MATIC',
      description: 'Polygon',
      isDefault: true,
      minimum: 0,
    ),
  ],
);

FakeBanxaApi _api({List<CryptoCurrency>? cryptos}) => FakeBanxaApi(
  fiats: [_usd, _eur],
  cryptos: cryptos ?? [_gnus],
  quote: Quote(
    paymentMethodId: 'card',
    cryptoAmount: '12.5',
    fiatAmount: '100.00',
    processingFee: '2',
    networkFee: '1',
  ),
  createResult: OrderResponse(
    orderId: 'ord_1',
    checkoutUrl: 'https://checkout.example/x',
  ),
);

class _Rig {
  _Rig({
    required this.api,
    required this.wallets,
    required this.orders,
    required this.router,
  });

  final FakeBanxaApi api;
  final PickableWalletCubit wallets;
  final OrdersCubit orders;
  final GoRouter router;
  bool disclaimerAccepted = false;
  int disclaimerSaves = 0;
}

Future<_Rig> _pumpCard(
  WidgetTester tester, {
  FakeBanxaApi? api,
  Wallet? wallet,
  bool noWallet = false,
  String fiat = 'USD',
  GWColors? gw,
  Size size = const Size(800, 1400),
  bool disclaimerAccepted = true,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final fake = api ?? _api();
  late final _Rig rig;
  final router = GoRouter(
    initialLocation: '/buy',
    routes: [
      GoRoute(
        path: '/buy',
        builder: (_, _) => BanxaBuyScreen(
          initialFiatCode: fiat,
          originLabel: 'HOME',
          createCubit: (a) => BuyGnusCubit(
            a,
            readDisclaimerAccepted: () => rig.disclaimerAccepted,
            saveDisclaimerAccepted: () async {
              rig.disclaimerAccepted = true;
              rig.disclaimerSaves++;
            },
          ),
        ),
      ),
      GoRoute(
        path: '/checkout',
        builder: (_, state) =>
            Text('checkout ${(state.extra as Map)['orderId']}'),
      ),
      GoRoute(
        path: '/transactions',
        builder: (_, state) => Text('transactions ?${state.uri.query}'),
      ),
    ],
  );
  rig = _Rig(
    api: fake,
    wallets: PickableWalletCubit(
      noWallet ? null : (wallet ?? testWallet(_address)),
    ),
    orders: OrdersCubit(api: fake),
    router: router,
  )..disclaimerAccepted = disclaimerAccepted;
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        RepositoryProvider<BanxaApiService>.value(value: fake),
        BlocProvider<WalletDetailsCubit>.value(value: rig.wallets),
        BlocProvider<OrdersCubit>.value(value: rig.orders),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: ThemeData(extensions: [gw ?? GWColors.dark()]),
      ),
    ),
  );
  await _settle(tester);
  return rig;
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 30));
  }
}

// Unmounting closes the cubit, which cancels its quote timer.
Future<void> _unmount(WidgetTester tester) =>
    tester.pumpWidget(const SizedBox());

GWButton _cta(WidgetTester tester) => tester.widget<GWButton>(
  find.byWidgetPredicate(
    (w) => w is GWButton && w.variant == GWButtonVariant.gradient,
  ),
);

void main() {
  group('pay and get', () {
    testWidgets('USD has one method: card text, chips, quote and fee rows', (
      tester,
    ) async {
      await _pumpCard(tester);

      expect(find.text('YOU PAY'), findsOneWidget);
      expect(find.text('YOU GET'), findsOneWidget);
      expect(find.text('US Dollar (USD)'), findsNothing);
      expect(find.text('USD'), findsOneWidget);
      expect(find.text('Paid by card'), findsOneWidget);
      expect(find.text('PAY WITH'), findsNothing);
      expect(find.text(r'Min $20 · Max $15,000'), findsOneWidget);
      for (final chip in [r'$50', r'$100', r'$250', r'$500']) {
        expect(find.text(chip), findsOneWidget);
      }
      expect(find.text('~12.5 GNUS'), findsOneWidget);
      expect(find.text('1 GNUS = 8.00 USD'), findsOneWidget);
      expect(find.text('Banxa processing fee'), findsOneWidget);
      expect(find.text(r'$2.00'), findsOneWidget);
      expect(find.text('Network fee'), findsOneWidget);
      expect(find.text(r'$1.00'), findsOneWidget);
      expect(find.text('New quote in 10s'), findsOneWidget);
      expect(find.text('Banxa may ask for ID at checkout.'), findsOneWidget);
      expect(_cta(tester).label, 'Buy GNUS');
      await _unmount(tester);
    });

    testWidgets('the old form controls are gone', (tester) async {
      await _pumpCard(tester);

      expect(find.text('Get quote'), findsNothing);
      expect(find.text('Verify with Banxa'), findsNothing);
      expect(find.text('WALLET ADDRESS'), findsNothing);
      expect(find.text('Wallet address'), findsNothing);
      expect(find.text('CRYPTO CURRENCY'), findsNothing);
      expect(find.text('Crypto currency'), findsNothing);
      expect(find.byType(DropdownMenu), findsNothing);
      await _unmount(tester);
    });

    testWidgets('EUR has two methods: a track, and picking one re-quotes', (
      tester,
    ) async {
      final rig = await _pumpCard(tester, fiat: 'EUR');

      expect(find.text('PAY WITH'), findsOneWidget);
      expect(find.text('Paid by card'), findsNothing);
      expect(find.text('SEPA'), findsOneWidget);
      expect(rig.api.quoteRequests.last['paymentMethodId'], 'sepa');

      await tester.tap(find.text('Card'));
      await _settle(tester);

      expect(rig.api.quoteRequests.last['paymentMethodId'], 'eurcard');
      await _unmount(tester);
    });

    testWidgets('an amount below the minimum says so and blocks the button', (
      tester,
    ) async {
      final rig = await _pumpCard(tester);

      await tester.enterText(find.byType(TextField), '5');
      await tester.pump(const Duration(milliseconds: 700));
      await _settle(tester);

      expect(find.text(r'Minimum is $20'), findsOneWidget);
      expect(find.text(r'Enter at least $20'), findsOneWidget);
      expect(_cta(tester).onPressed, isNull);
      expect(find.text('-'), findsWidgets);
      expect(rig.api.quoteRequests.length, 1);
      await _unmount(tester);
    });

    testWidgets('a chip writes the amount and re-quotes it', (tester) async {
      final rig = await _pumpCard(tester);

      await tester.tap(find.text(r'$250'));
      await tester.pump(const Duration(milliseconds: 700));
      await _settle(tester);

      expect(rig.api.quoteRequests.last['fiatAmount'], '250');
      expect(find.text('250'), findsOneWidget);
      await _unmount(tester);
    });

    testWidgets('a stale quote offers Refresh and recovers on tap', (
      tester,
    ) async {
      final rig = await _pumpCard(tester);
      rig.api.quoteError = Exception('down');

      await tester.pump(const Duration(seconds: 11));
      await _settle(tester);

      expect(find.text('Quote out of date'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);
      expect(_cta(tester).label, 'Refresh quote');
      expect(_cta(tester).onPressed, isNotNull);

      rig.api.quoteError = null;
      await tester.tap(find.text('Refresh'));
      await _settle(tester);

      expect(find.text('Quote out of date'), findsNothing);
      expect(find.text('~12.5 GNUS'), findsOneWidget);
      await _unmount(tester);
    });

    testWidgets('the currency pill opens a searchable list and switches', (
      tester,
    ) async {
      final rig = await _pumpCard(tester);

      await tester.tap(find.bySemanticsLabel('Change currency'));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Euro (EUR)'), findsOneWidget);
      expect(find.text('US Dollar (USD)'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'eur');
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('US Dollar (USD)'), findsNothing);

      await tester.tap(find.text('Euro (EUR)'));
      await tester.pump(const Duration(milliseconds: 400));
      await _settle(tester);

      expect(find.text('EUR'), findsOneWidget);
      expect(rig.api.quoteRequests.last['fiat'], 'EUR');
      await _unmount(tester);
    });
  });
}
