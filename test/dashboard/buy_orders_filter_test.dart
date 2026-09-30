import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/dashboard/home/widgets/transactions_slim_view.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/dashboard/transactions/transactions_screen.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

import '../banxa/fake_banxa_api.dart';
import '../banxa/fixtures.dart';

const _address = '0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';

Transaction _plain() => Transaction(
  hash: '0xabc',
  fromAddress: '0x1111',
  recipients: [TransferRecipients(toAddr: '0x2222', amount: '1.0')],
  timeStamp: DateTime.now(),
  transactionDirection: TransactionDirection.sent,
  fees: '0.001',
  coinSymbol: 'ETH',
  transactionStatus: TransactionStatus.completed,
  type: TransactionType.transfer,
);

/// Two orders; `ord_new` is the more recent, so it is the first row.
FakeBanxaApi _api() => FakeBanxaApi(
  orders: [
    testOrder(
      id: 'ord_old',
      cryptoId: 'GNUS',
      createdAt: DateTime.utc(2026, 1, 1),
    ),
    testOrder(
      id: 'ord_new',
      cryptoId: 'GNUS',
      createdAt: DateTime.utc(2026, 2, 1),
    ),
  ],
);

Future<GoRouter> _pump(WidgetTester tester, {required String at}) async {
  tester.view.physicalSize = const Size(1280 * 3, 900 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final wallets = PickableWalletCubit(testWallet(_address));
  final router = GoRouter(
    initialLocation: at,
    routes: [
      GoRoute(
        path: '/transactions',
        builder: (_, state) => TransactionsScreen(
          initialFilter: filterFromQuery(state.uri.queryParameters['filter']),
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<WalletDetailsCubit>.value(value: wallets),
        BlocProvider(create: (_) => TransactionsCubit(initial: [_plain()])),
        BlocProvider(
          create: (_) => OrdersCubit(walletDetailsCubit: wallets, api: _api()),
        ),
      ],
      child: MaterialApp.router(
        theme: ThemeData(extensions: [GWColors.dark()]),
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  late List<String> copied;

  setUp(() {
    copied = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  test('filterFromQuery maps only known filter names', () {
    expect(filterFromQuery('purchase'), Filters.purchase);
    expect(filterFromQuery('nonsense'), isNull);
    expect(filterFromQuery(null), isNull);
  });

  testWidgets('the purchase filter in the URL lists the orders and hides the '
      'plain transaction', (tester) async {
    await _pump(tester, at: '/transactions?filter=purchase');

    expect(find.byType(TransactionRow), findsNWidgets(2));
  });

  testWidgets('without the filter, orders sit beside the other rows', (
    tester,
  ) async {
    await _pump(tester, at: '/transactions');

    expect(find.byType(TransactionRow), findsNWidgets(3));
  });

  testWidgets('tapping an order row opens its drawer, and Order ID copies '
      'exactly the id', (tester) async {
    await _pump(tester, at: '/transactions?filter=purchase');

    await tester.tap(find.byType(TransactionRow).first);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Order ID'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Order ID'));
    await tester.pumpAndSettle();

    expect(copied, ['ord_new']);
  });

  testWidgets('going to the filtered URL while on the page switches the '
      'chip', (tester) async {
    final router = await _pump(tester, at: '/transactions');
    expect(find.byType(TransactionRow), findsNWidgets(3));

    router.go('/transactions?filter=purchase');
    await tester.pumpAndSettle();

    expect(find.byType(TransactionRow), findsNWidgets(2));
  });
}
