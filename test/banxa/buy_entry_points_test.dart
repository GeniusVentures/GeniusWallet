import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/coins/view/coins_screen.dart';
import 'package:genius_wallet/dashboard/assets/assets_screen.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/dashboard/transactions/transactions_screen.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/tokens/token_info_args.dart';
import 'package:genius_wallet/tokens/token_info_screen.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

import 'fake_banxa_api.dart';

class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _NoNetworks extends NetworkProvider {
  @override
  List<Network> get networks => const [];
}

const _amoy = Network(
  name: 'Polygon Amoy',
  symbol: 'matic',
  chainId: 80002,
  rpcUrl: 'https://rpc.invalid',
);

const _wallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Test Wallet',
  currencySymbol: 'MATIC',
  walletType: WalletType.mnemonic,
  balance: 0,
  address: '0x1234567890123456789012345678901234567890',
);

WalletDetailsCubit _cubit({
  List<Coin> coins = const [],
  Coin? selected,
  bool seedWallet = false,
}) => WalletDetailsCubit(
  initialState: WalletDetailsState(
    coins: coins,
    coinsStatus: WalletStatus.successful,
    selectedCoin: selected,
    selectedWallet: seedWallet ? _wallet : null,
    selectedNetwork: seedWallet ? _amoy : null,
    coinsNetwork: seedWallet ? _amoy : null,
  ),
  geniusApi: _UnusedApi(),
  networkTokensProvider: NetworkTokensProvider(),
);

/// Hosts [home] at '/' and records the extra of every push to '/buy'.
Widget _app(
  Widget home,
  List<Object?> buyExtras, {
  GWColors? colors,
  List<BlocProvider> providers = const [],
}) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => home),
      GoRoute(
        path: '/buy',
        builder: (_, state) {
          buyExtras.add(state.extra);
          return const Scaffold(body: Text('buy placeholder'));
        },
      ),
    ],
  );
  Widget app = MaterialApp.router(
    theme: ThemeData(extensions: [colors ?? GWColors.dark()]),
    routerConfig: router,
  );
  if (providers.isNotEmpty) {
    app = MultiBlocProvider(providers: providers, child: app);
  }
  return app;
}

void _size(WidgetTester tester, double width, double height) {
  tester.view.physicalSize = Size(width * 2, height * 2);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _coinPage(WalletDetailsCubit cubit) =>
    TokenInfoScreen(walletDetailsCubit: cubit, args: const TokenInfoArgs());

const _gnus = Coin(symbol: 'GNUS', address: '0xabc', balance: 10);
const _usdc = Coin(symbol: 'USDC', address: '0xdef', balance: 10);

void main() {
  testWidgets('Home: Buy GNUS pushes /buy', (tester) async {
    _size(tester, 600, 900);
    final extras = <Object?>[];
    final cubit = _cubit(
      coins: [
        for (final s in ['AAA', 'BBB']) Coin(name: s, symbol: s, balance: 1),
      ],
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      _app(
        const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 600, height: 500, child: CoinsScreen()),
        ),
        extras,
        providers: [BlocProvider<WalletDetailsCubit>.value(value: cubit)],
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Buy GNUS'));
    await tester.pumpAndSettle();

    expect(extras, [null]);
  });

  testWidgets('Assets: Buy GNUS pushes /buy', (tester) async {
    _size(tester, 390, 844);
    final extras = <Object?>[];
    final cubit = _cubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      _app(
        AssetsScreen(resolveMarketData: (_) => Future.value(const {})),
        extras,
        providers: [BlocProvider<WalletDetailsCubit>.value(value: cubit)],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Buy GNUS'));
    await tester.pumpAndSettle();

    expect(extras, [null]);
  });

  testWidgets('GNUS coin page: Buy pushes /buy', (tester) async {
    _size(tester, 1000, 900);
    final extras = <Object?>[];
    final cubit = _cubit(coins: [_gnus], selected: _gnus, seedWallet: true);
    addTearDown(cubit.close);

    await tester.pumpWidget(_app(_coinPage(cubit), extras));
    await tester.pump();

    await tester.tap(find.text('Buy'));
    await tester.pumpAndSettle();

    expect(extras, [null]);
  });

  testWidgets('a coin page that is not GNUS has no Buy', (tester) async {
    _size(tester, 1000, 900);
    final cubit = _cubit(coins: [_usdc], selected: _usdc, seedWallet: true);
    addTearDown(cubit.close);

    await tester.pumpWidget(_app(_coinPage(cubit), []));
    await tester.pump();

    expect(find.text('Swap'), findsOneWidget);
    expect(find.text('Buy'), findsNothing);
  });

  for (final (name, colors) in [
    ('dark', GWColors.dark()),
    ('light', GWColors.light()),
  ]) {
    testWidgets('GNUS coin page at 360px wide does not overflow ($name)', (
      tester,
    ) async {
      _size(tester, 360, 800);
      final cubit = _cubit(coins: [_gnus], selected: _gnus, seedWallet: true);
      addTearDown(cubit.close);

      await tester.pumpWidget(_app(_coinPage(cubit), [], colors: colors));
      await tester.pump();

      // All five actions present, so the row really did have to wrap.
      for (final label in ['Swap', 'Send', 'Receive', 'Bridge', 'Buy']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(find.text('Checking your GNUS balance.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Transactions: the header Buy GNUS pushes /buy '
      'TRANSACTIONS', (tester) async {
    _size(tester, 1000, 900);
    final extras = <Object?>[];
    final transactions = TransactionsCubit(initial: const []);
    final wallet = _cubit(seedWallet: true);
    final appBloc = AppBloc(
      api: _UnusedApi(),
      transactionsCubit: transactions,
      walletDetailsCubit: wallet,
      networkProvider: _NoNetworks(),
    );
    final orders = OrdersCubit(api: FakeBanxaApi());

    await tester.pumpWidget(
      _app(
        const TransactionsScreen(),
        extras,
        providers: [
          BlocProvider<WalletDetailsCubit>.value(value: wallet),
          BlocProvider<TransactionsCubit>.value(value: transactions),
          BlocProvider<AppBloc>.value(value: appBloc),
          BlocProvider<OrdersCubit>.value(value: orders),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Buy GNUS'));
    await tester.pumpAndSettle();

    expect(extras, [null]);

    // Cancels the bloc's periodic poll, which would otherwise fail the test.
    await tester.runAsync(appBloc.close);
    await wallet.close();
    await orders.close();
  });
}
