import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/banxa/banxa_api_services.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/buy_gnus_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/buy_gnus_state.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/providers/network_provider.dart';
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
  bool light = false,
  Size size = const Size(800, 1400),
  bool disclaimerAccepted = true,
  AppBloc? appBloc,
  PickableWalletCubit? wallets,
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
    wallets:
        wallets ??
        PickableWalletCubit(noWallet ? null : (wallet ?? testWallet(_address))),
    orders: OrdersCubit(api: fake),
    router: router,
  )..disclaimerAccepted = disclaimerAccepted;
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        RepositoryProvider<BanxaApiService>.value(value: fake),
        BlocProvider<WalletDetailsCubit>.value(value: rig.wallets),
        BlocProvider<OrdersCubit>.value(value: rig.orders),
        if (appBloc != null) BlocProvider<AppBloc>.value(value: appBloc),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: ThemeData(
          brightness: light ? Brightness.light : Brightness.dark,
          extensions: [light ? GWColors.light() : GWColors.dark()],
        ),
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

GWButton _cta(WidgetTester tester) =>
    tester.widget<GWButton>(find.byWidgetPredicate(_isBuyButton));

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

  group('where GNUS goes', () {
    testWidgets('the To row names the Selected wallet and its short address', (
      tester,
    ) async {
      await _pumpCard(tester);

      expect(find.text('TO'), findsOneWidget);
      expect(find.text('Wallet'), findsOneWidget);
      expect(find.text('0x5aAe...eAed'), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);
      expect(find.text(BuyGnusState.watchOnlyReason), findsNothing);
      await _unmount(tester);
    });

    testWidgets('Change opens the account switcher', (tester) async {
      final wallets = PickableWalletCubit(testWallet(_address));
      final appBloc = _SeededAppBloc(wallets, [testWallet(_address)]);
      try {
        await _pumpCard(tester, appBloc: appBloc, wallets: wallets);

        await tester.tap(find.text('Change'));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Accounts'), findsOneWidget);
        expect(find.text('Add wallet'), findsOneWidget);

        await tester.tap(find.byTooltip('Close'));
        await tester.pump(const Duration(milliseconds: 500));
        await _unmount(tester);
      } finally {
        await tester.runAsync(() => appBloc.close());
      }
    });

    testWidgets('a watch-only wallet gives the reason and a disabled button', (
      tester,
    ) async {
      await _pumpCard(
        tester,
        wallet: testWallet(_address, type: WalletType.tracking),
      );

      expect(find.text(BuyGnusState.watchOnlyReason), findsOneWidget);
      expect(_cta(tester).label, 'Buy GNUS');
      expect(_cta(tester).onPressed, isNull);
      await _unmount(tester);
    });

    testWidgets('with no wallet the card says to add one', (tester) async {
      await _pumpCard(tester, noWallet: true);

      expect(find.text('No wallet to receive GNUS'), findsOneWidget);
      expect(
        find.text(
          'Add or import a wallet first. GNUS is delivered straight to it.',
        ),
        findsOneWidget,
      );
      expect(find.text('Change'), findsOneWidget);
      expect(_cta(tester).label, 'Add a wallet to buy');
      expect(_cta(tester).onPressed, isNull);
      await _unmount(tester);
    });
  });

  group('when the card cannot sell', () {
    void expectNoForm() {
      expect(find.byType(TextField), findsNothing);
      expect(find.text('YOU PAY'), findsNothing);
      expect(find.text('YOU GET'), findsNothing);
      expect(find.text('TO'), findsNothing);
      expect(find.byWidgetPredicate(_isBuyButton), findsNothing);
    }

    testWidgets('GNUS unlisted says so and Check again reloads', (
      tester,
    ) async {
      final api = _api(cryptos: const []);
      await _pumpCard(tester, api: api);

      expect(find.text("GNUS isn't on Banxa yet"), findsOneWidget);
      expect(
        find.text(
          "Banxa doesn't sell GNUS yet. Buying opens here as soon as it does.",
        ),
        findsOneWidget,
      );
      expectNoForm();

      api.cryptos = [_gnus];
      await tester.tap(find.text('Check again'));
      await _settle(tester);

      expect(find.text("GNUS isn't on Banxa yet"), findsNothing);
      expect(find.text('YOU PAY'), findsOneWidget);
      await _unmount(tester);
    });

    testWidgets('a build with no key says buying is not set up', (
      tester,
    ) async {
      final api = _api()..isConfigured = false;
      await _pumpCard(tester, api: api);

      expect(find.text("Buying isn't set up in this build"), findsOneWidget);
      expect(
        find.text(
          'This build has no Banxa connection. Use an official release to buy GNUS.',
        ),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsNothing);
      expect(find.text('Check again'), findsNothing);
      expectNoForm();
      await _unmount(tester);
    });

    testWidgets('a failed load offers Try again', (tester) async {
      final api = _api()..listError = Exception('offline');
      await _pumpCard(tester, api: api);

      expect(find.text("Couldn't reach Banxa"), findsOneWidget);
      expect(find.text('Check your connection and try again.'), findsOneWidget);
      expectNoForm();

      api.listError = null;
      await tester.tap(find.text('Try again'));
      await _settle(tester);

      expect(find.text("Couldn't reach Banxa"), findsNothing);
      expect(find.text('YOU PAY'), findsOneWidget);
      await _unmount(tester);
    });
  });

  group('sandbox, orders link and fit', () {
    testWidgets('the sandbox pill shows only for a sandbox client', (
      tester,
    ) async {
      await _pumpCard(tester);
      expect(find.text('Sandbox · no real money'), findsNothing);
      await _unmount(tester);

      await _pumpCard(tester, api: _api()..isSandbox = true);
      expect(find.text('Sandbox · no real money'), findsOneWidget);
      await _unmount(tester);
    });

    testWidgets('Buy orders opens Transactions on the buy filter', (
      tester,
    ) async {
      await _pumpCard(tester);

      await tester.tap(find.text('Buy orders'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('transactions ?filter=purchase'), findsOneWidget);
      await _unmount(tester);
    });

    for (final light in [false, true]) {
      for (final size in const [Size(360, 800), Size(1280, 800)]) {
        testWidgets(
          'the busiest card fits ${size.width.toInt()}x${size.height.toInt()} '
          'in ${light ? 'light' : 'dark'}',
          (tester) async {
            await _pumpCard(
              tester,
              api: _api()..isSandbox = true,
              fiat: 'EUR',
              light: light,
              size: size,
              wallet: testWallet(_address, type: WalletType.tracking),
            );

            expect(find.text('PAY WITH'), findsOneWidget);
            expect(find.text(BuyGnusState.watchOnlyReason), findsOneWidget);
            expect(tester.takeException(), isNull);
            await _unmount(tester);
          },
        );
      }
    }
  });
}

bool _isBuyButton(Widget w) =>
    w is GWButton && w.variant == GWButtonVariant.gradient;

class _SeededAppBloc extends AppBloc {
  _SeededAppBloc(PickableWalletCubit wallets, List<Wallet> seeded)
    : super(
        api: UnusedGeniusApi(),
        transactionsCubit: TransactionsCubit(),
        walletDetailsCubit: wallets,
        networkProvider: NetworkProvider(),
      ) {
    emit(state.copyWith(wallets: seeded));
  }
}
