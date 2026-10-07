import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/banxa_components/order_drawer_footer.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_status.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'fixtures.dart';

String? _launched;

class _RecordingLauncher extends UrlLauncherPlatform {
  @override
  final LinkDelegate? linkDelegate = null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launch(
    String url, {
    required bool useSafariVC,
    required bool useWebView,
    required bool enableJavaScript,
    required bool enableDomStorage,
    required bool universalLinksOnly,
    required Map<String, String> headers,
    String? webOnlyWindowName,
  }) async {
    _launched = url;
    return true;
  }
}

Order _untrusted(String status) {
  final json = testOrder(status: status).toJson();
  json['orderStatusUrl'] = 'https://evilbanxa.com/pay';
  return Order.fromJson(json);
}

/// Extras of the routes the footer pushed, in order.
final extras = <Object?>[];

/// Pushes the footer as its own route, so popping it is observable.
Future<void> _pump(WidgetTester tester, Order order) async {
  extras.clear();
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const Text('home')),
      GoRoute(
        path: '/drawer',
        builder: (_, _) => Scaffold(body: OrderDrawerFooter(order: order)),
      ),
      GoRoute(
        path: '/checkout',
        builder: (_, state) {
          extras.add(state.extra);
          return const Text('checkout page');
        },
      ),
      GoRoute(
        path: '/buy',
        builder: (_, state) {
          extras.add(state.extra);
          return const Text('buy page');
        },
      ),
    ],
  );
  await tester.pumpWidget(
    MaterialApp.router(
      theme: ThemeData(extensions: [GWColors.dark()]),
      routerConfig: router,
    ),
  );
  unawaited(router.push('/drawer'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    _launched = null;
    UrlLauncherPlatform.instance = _RecordingLauncher();
  });

  testWidgets('every status states what it means', (tester) async {
    for (final status in BanxaOrderStatus.values) {
      await _pump(tester, testOrder(status: status.name));
      expect(
        find.text(status.description),
        findsOneWidget,
        reason: status.name,
      );
    }
  });

  testWidgets('an unpaid order reopens checkout for that order', (
    tester,
  ) async {
    await _pump(tester, testOrder(status: 'pendingPayment', id: 'ord_9'));

    await tester.tap(find.text('Complete payment'));
    await tester.pumpAndSettle();

    expect(find.text('checkout page'), findsOneWidget);
    expect(find.byType(OrderDrawerFooter), findsNothing);
    expect(extras.single, {
      'orderId': 'ord_9',
      'checkoutUrl': 'https://banxa-sandbox.com/orders/ord_9',
    });
    expect(find.text('Contact Banxa support'), findsNothing);
  });

  testWidgets('an untrusted link never reopens checkout', (tester) async {
    await _pump(tester, _untrusted('pendingPayment'));
    expect(find.text('Complete payment'), findsNothing);

    await _pump(tester, _untrusted('extraVerification'));
    expect(find.text('Continue verification'), findsNothing);
    expect(find.text('Contact Banxa support'), findsOneWidget);
  });

  testWidgets('a needs-ID order continues verification and offers support', (
    tester,
  ) async {
    await _pump(tester, testOrder(status: 'extraVerification', id: 'ord_2'));

    expect(find.text('Complete payment'), findsNothing);
    expect(find.text('Contact Banxa support'), findsOneWidget);
    await tester.tap(find.text('Continue verification'));
    await tester.pumpAndSettle();

    expect(find.text('checkout page'), findsOneWidget);
    expect((extras.single as Map)['orderId'], 'ord_2');
  });

  for (final status in ['declined', 'expired', 'cancelled']) {
    testWidgets('an order that is $status offers Try again with its amount', (
      tester,
    ) async {
      await _pump(
        tester,
        testOrder(status: status, fiat: 'EUR', fiatAmount: '75'),
      );

      expect(find.text('Complete payment'), findsNothing);
      expect(
        find.text('Contact Banxa support'),
        status == 'cancelled' ? findsNothing : findsOneWidget,
      );
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.text('buy page'), findsOneWidget);
      expect(extras.single, {'fiat': 'EUR', 'amount': '75'});
    });
  }

  testWidgets('a refunded order offers support only', (tester) async {
    await _pump(tester, testOrder(status: 'refunded'));

    expect(find.text('Try again'), findsNothing);
    expect(find.text('Complete payment'), findsNothing);
    await tester.tap(find.text('Contact Banxa support'));
    await tester.pumpAndSettle();

    expect(_launched, 'https://support.banxa.com');
  });

  testWidgets('complete and in-flight orders show the status line only', (
    tester,
  ) async {
    for (final status in [
      'complete',
      'waitingPayment',
      'paymentReceived',
      'inProgress',
      'cryptoTransferred',
      'nonsense',
    ]) {
      await _pump(tester, testOrder(status: status));
      expect(find.text('Try again'), findsNothing);
      expect(find.text('Complete payment'), findsNothing);
      expect(find.text('Contact Banxa support'), findsNothing, reason: status);
    }
  });
}
