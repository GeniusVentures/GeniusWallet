import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/banxa_components/buy_order_toasts.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:go_router/go_router.dart';

import 'fake_banxa_api.dart';
import 'fixtures.dart';

const _address = '0xAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaAa';
const _tick = Duration(seconds: 15);

class _Harness {
  _Harness(this.api, this.cubit, this.router);

  final FakeBanxaApi api;
  final OrdersCubit cubit;
  final GoRouter router;
}

Future<_Harness> _pump(
  WidgetTester tester, {
  required List<Order> orders,
  Map<String, List<String>> script = const {},
  String at = '/',
}) async {
  tester.view.physicalSize = const Size(1280 * 2, 900 * 2);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final key = GlobalKey<NavigatorState>();
  final api = FakeBanxaApi(orders: orders);
  script.forEach((id, statuses) => api.statuses[id] = [...statuses]);
  final cubit = OrdersCubit(
    walletDetailsCubit: PickableWalletCubit(testWallet(_address)),
    api: api,
  );
  final router = GoRouter(
    navigatorKey: key,
    initialLocation: at,
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('home page')),
      ),
      GoRoute(
        path: '/checkout',
        builder: (_, _) => const Scaffold(body: Text('checkout page')),
      ),
    ],
  );
  await tester.pumpWidget(
    BlocProvider<OrdersCubit>.value(
      value: cubit,
      child: MaterialApp.router(
        theme: ThemeData(extensions: [GWColors.dark()]),
        routerConfig: router,
        builder: (context, child) =>
            BuyOrderToasts(navigatorKey: key, child: child!),
      ),
    ),
  );
  await tester.pump();
  return _Harness(api, cubit, router);
}

Future<void> _finish(WidgetTester tester, _Harness h) async {
  ToastManager.instance.disposeAll();
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
  // Not awaited: the close finishes on the fake clock, so a pump drives it.
  unawaited(h.cubit.close());
  await tester.pump();
}

Order _pending(String id) => testOrder(id: id, status: 'pendingPayment');

void main() {
  tearDown(() => ToastManager.instance.disposeAll());

  testWidgets('a completed order toasts once, however long polling goes on', (
    tester,
  ) async {
    final h = await _pump(
      tester,
      orders: [_pending('ord_1')],
      script: {
        'ord_1': ['complete'],
      },
    );

    await tester.pump(_tick);
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('GNUS is in your wallet'), findsOneWidget);
    expect(find.text('0.0025 GNUS from your Banxa order arrived.'), findsOne);
    expect(find.text('View order'), findsOneWidget);

    ToastManager.instance.disposeAll();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(_tick * 3);
    expect(find.text('GNUS is in your wallet'), findsNothing);
    expect(h.api.readIds, ['ord_1']);

    await _finish(tester, h);
  });

  testWidgets('View order opens that order in the details drawer', (
    tester,
  ) async {
    final copied = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    final h = await _pump(
      tester,
      orders: [_pending('ord_1')],
      script: {
        'ord_1': ['complete'],
      },
    );
    await tester.pump(_tick);
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('View order'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Order ID'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Order ID'));
    await tester.pumpAndSettle();
    expect(copied, ['ord_1']);

    await _finish(tester, h);
  });

  testWidgets('a declined order says nothing was charged', (tester) async {
    final h = await _pump(
      tester,
      orders: [_pending('ord_1')],
      script: {
        'ord_1': ['declined'],
      },
    );
    await tester.pump(_tick);
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Payment declined'), findsOneWidget);
    expect(
      find.text('Your bank or card declined it. You were not charged.'),
      findsOneWidget,
    );

    await _finish(tester, h);
  });

  testWidgets('a refund names the amount returned', (tester) async {
    final h = await _pump(
      tester,
      orders: [_pending('ord_1')],
      script: {
        'ord_1': ['refunded'],
      },
    );
    await tester.pump(_tick);
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Order refunded'), findsOneWidget);
    expect(find.text('Banxa refunded 100.00 USD to your card.'), findsOne);

    await _finish(tester, h);
  });

  testWidgets('an order that was already final at load never toasts', (
    tester,
  ) async {
    final h = await _pump(
      tester,
      orders: [testOrder(id: 'ord_1', status: 'complete')],
    );
    await tester.pump(_tick * 3);
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('GNUS is in your wallet'), findsNothing);
    expect(ToastManager.instance.visibleCount, 0);

    await _finish(tester, h);
  });

  testWidgets('nothing toasts while checkout is showing', (tester) async {
    final h = await _pump(
      tester,
      orders: [_pending('ord_1')],
      script: {
        'ord_1': ['complete'],
      },
      at: '/checkout',
    );
    expect(find.text('checkout page'), findsOneWidget);

    await tester.pump(_tick);
    await tester.pump(const Duration(milliseconds: 400));

    expect(h.api.readIds, ['ord_1']);
    expect(find.text('GNUS is in your wallet'), findsNothing);
    expect(ToastManager.instance.visibleCount, 0);

    await _finish(tester, h);
  });

  testWidgets('leaving the app pauses polling and coming back reads at once', (
    tester,
  ) async {
    final h = await _pump(tester, orders: [_pending('ord_1')]);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(_tick * 4);
    expect(h.api.readIds, isEmpty);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(h.api.readIds, ['ord_1']);

    await _finish(tester, h);
  });
}
