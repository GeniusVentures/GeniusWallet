import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/controllers/sgnus_transactions_controller.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
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

/// Answers only the SGNUS feed, with no rows of its own.
class _SgnusApi extends UnusedGeniusApi {
  final _feed = SGNUSTransactionsController();

  @override
  SGNUSTransactionsController getSGNUSTransactionsController() => _feed;
}

/// Two orders; `ord_new` is the more recent, so it is the first row. [open]
/// adds that many unpaid ones.
FakeBanxaApi _api({bool withOrders = true, int open = 0}) => FakeBanxaApi(
  orders: withOrders
      ? [
          for (var i = 0; i < open; i++)
            testOrder(id: 'ord_open_$i', status: 'pendingPayment'),
          testOrder(
            id: 'ord_old',
            status: 'complete',
            cryptoId: 'GNUS',
            createdAt: DateTime.utc(2026, 1, 1),
          ),
          testOrder(
            id: 'ord_new',
            status: 'complete',
            cryptoId: 'GNUS',
            createdAt: DateTime.utc(2026, 2, 1),
          ),
        ]
      : [],
);

Future<GoRouter> _pump(
  WidgetTester tester, {
  required String at,
  double width = 1280,
  bool settle = true,
  bool withOrders = true,
  int open = 0,
  WalletType walletType = WalletType.privateKey,
  void Function(Object? extra)? onBuy,
  void Function(Object? extra)? onCheckout,
}) async {
  tester.view.physicalSize = Size(width * 3, 900 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final wallets = PickableWalletCubit(testWallet(_address, type: walletType));
  final router = GoRouter(
    initialLocation: at,
    routes: [
      GoRoute(
        path: '/buy',
        builder: (_, state) {
          onBuy?.call(state.extra);
          return const Scaffold(body: Text('buy page'));
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (_, state) {
          onCheckout?.call(state.extra);
          return const Scaffold(body: Text('checkout page'));
        },
      ),
      GoRoute(
        path: '/banxa/callback',
        redirect: (_, _) => '/transactions?filter=purchase',
      ),
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
        RepositoryProvider<GeniusApi>.value(value: _SgnusApi()),
        BlocProvider<WalletDetailsCubit>.value(value: wallets),
        BlocProvider(create: (_) => TransactionsCubit(initial: [_plain()])),
        BlocProvider(
          create: (_) => OrdersCubit(
            walletDetailsCubit: wallets,
            api: _api(withOrders: withOrders, open: open),
          ),
        ),
      ],
      child: MaterialApp.router(
        theme: ThemeData(extensions: [GWColors.dark()]),
        routerConfig: router,
      ),
    ),
  );
  // The phone layout's background animates forever, so it cannot settle.
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(milliseconds: 300));
  }
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

  testWidgets('an unpaid order row uses the short status word', (tester) async {
    await _pump(tester, at: '/transactions?filter=purchase', open: 1);

    expect(find.text('Unpaid'), findsOneWidget);
    expect(find.text('Pending Payment'), findsNothing);
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

  testWidgets('an unpaid order drawer reopens that order in checkout', (
    tester,
  ) async {
    Object? extra;
    await _pump(
      tester,
      at: '/transactions?filter=purchase',
      open: 1,
      onCheckout: (e) => extra = e,
    );

    await tester.tap(find.text('Unpaid'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Complete payment'));
    await tester.tap(find.text('Complete payment'));
    await tester.pumpAndSettle();

    expect(find.text('checkout page'), findsOneWidget);
    expect((extra as Map)['orderId'], 'ord_open_0');
  });

  testWidgets('going to the filtered URL while on the page switches the '
      'chip', (tester) async {
    final router = await _pump(tester, at: '/transactions');
    expect(find.byType(TransactionRow), findsNWidgets(3));

    router.go('/transactions?filter=purchase');
    await tester.pumpAndSettle();

    expect(find.byType(TransactionRow), findsNWidgets(2));
  });

  testWidgets('the Banxa return link lands on Buy orders and ignores its '
      'query', (tester) async {
    await _pump(tester, at: '/banxa/callback?status=success&orderId=x');

    expect(find.byType(TransactionRow), findsNWidgets(2));
  });

  testWidgets('Buy orders is a chip in the bar, not in the More menu', (
    tester,
  ) async {
    await _pump(tester, at: '/transactions', width: 600, settle: false);

    expect(find.byTooltip('Buy orders'), findsOneWidget);

    await tester.tap(find.byTooltip('More filters'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Escrow'), findsOneWidget);
    expect(find.text('Buy orders'), findsNothing);
  });

  testWidgets('the Buy orders chip counts the open orders and says so', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pump(
      tester,
      at: '/transactions',
      width: 600,
      settle: false,
      open: 2,
    );

    expect(
      find.descendant(
        of: find.byTooltip('Buy orders'),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Buy orders, 2 open'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
    semantics.dispose();
  });

  testWidgets('with nothing open the chip carries no count', (tester) async {
    await _pump(tester, at: '/transactions', width: 600, settle: false);

    expect(
      find.descendant(
        of: find.byTooltip('Buy orders'),
        matching: find.byType(Text),
      ),
      findsNothing,
    );
  });

  testWidgets('with no orders, its empty state offers Buy GNUS', (
    tester,
  ) async {
    Object? extra;
    await _pump(
      tester,
      at: '/transactions?filter=purchase',
      withOrders: false,
      onBuy: (e) => extra = e,
    );

    expect(find.text('No buy orders yet'), findsOneWidget);
    // The page header carries its own Buy GNUS; this one is the empty state's.
    await tester.tap(
      find.descendant(
        of: find.byType(GWEmptyState),
        matching: find.text('Buy GNUS'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('buy page'), findsOneWidget);
    expect(extra, {'origin': 'TRANSACTIONS'});
  });

  testWidgets('an SGNUS Selected wallet lists its orders too', (tester) async {
    await _pump(
      tester,
      at: '/transactions?filter=purchase',
      walletType: WalletType.sgnus,
    );

    expect(find.byType(TransactionRow), findsNWidgets(2));
    await tester.pumpWidget(const SizedBox());
  });
}
