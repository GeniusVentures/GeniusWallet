import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/banxa_components/order_details_card.dart';
import 'package:genius_wallet/banxa/banxa_components/order_status_style.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:intl/intl.dart';

import 'fixtures.dart';
import 'gw_pump.dart';

/// Pins 09-04 Task 1's re-skin of `OrderDetailCard`: the four-bucket status
/// ladder this card never had (finding-4's missing error/neutral branches),
/// the shipped `OrderStatusBanner` tinted recipe replacing the opaque pastel
/// `Container`, the frozen row labels/values (D-01), and the wallet-address
/// masking toggle (T-09-12), all inside a bounded `SizedBox` since the card
/// builds a `ListView`.
void main() {
  Widget cardFor(
    String status, {
    String? bannerText,
    OrderStatusTone? bannerTone,
  }) => SizedBox(
    width: 360.0,
    height: 700.0,
    child: OrderDetailCard(
      order: testOrder(status: status),
      bannerText: bannerText,
      bannerTone: bannerTone,
      actionButton: const SizedBox.shrink(),
    ),
  );

  testWidgets('completed order shows a success-toned status', (tester) async {
    await tester.pumpWidget(gwHost(cardFor('completed')));
    final gw = GWColors.dark();
    final statusText = tester.widget<Text>(find.text('completed'));
    expect(statusText.style?.color, gw.statusSuccess);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pendingpayment order shows a warning-toned status', (
    tester,
  ) async {
    await tester.pumpWidget(gwHost(cardFor('pendingpayment')));
    final gw = GWColors.dark();
    final statusText = tester.widget<Text>(find.text('pendingpayment'));
    expect(statusText.style?.color, gw.statusWarning);
    expect(tester.takeException(), isNull);
  });

  for (final status in ['declined', 'expired', 'failed']) {
    testWidgets('$status order shows an error-toned status', (tester) async {
      await tester.pumpWidget(gwHost(cardFor(status)));
      final gw = GWColors.dark();
      final statusText = tester.widget<Text>(find.text(status));
      expect(statusText.style?.color, gw.statusError);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('unrecognised status shows a neutral-toned status', (
    tester,
  ) async {
    await tester.pumpWidget(gwHost(cardFor('onhold')));
    final gw = GWColors.dark();
    final statusText = tester.widget<Text>(find.text('onhold'));
    expect(statusText.style?.color, gw.textSecondary);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'a warning tone renders the banner text through OrderStatusBanner with a warning tone',
    (tester) async {
      const text = 'Checkout cancelled. Verifying order status…';
      await tester.pumpWidget(
        gwHost(
          cardFor(
            'pendingpayment',
            bannerText: text,
            bannerTone: OrderStatusTone.warning,
          ),
        ),
      );
      final banner = tester.widget<OrderStatusBanner>(
        find.byType(OrderStatusBanner),
      );
      expect(banner.text, text);
      expect(banner.tone, OrderStatusTone.warning);
      expect(find.text(text), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'an error tone renders the banner text through OrderStatusBanner with an error tone',
    (tester) async {
      const text = 'Payment failed. Verifying order status…';
      await tester.pumpWidget(
        gwHost(
          cardFor(
            'failed',
            bannerText: text,
            bannerTone: OrderStatusTone.error,
          ),
        ),
      );
      final banner = tester.widget<OrderStatusBanner>(
        find.byType(OrderStatusBanner),
      );
      expect(banner.text, text);
      expect(banner.tone, OrderStatusTone.error);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'a success tone renders the banner text through OrderStatusBanner with a success tone',
    (tester) async {
      const text = 'Payment completed. Fetching final details…';
      await tester.pumpWidget(
        gwHost(
          cardFor(
            'completed',
            bannerText: text,
            bannerTone: OrderStatusTone.success,
          ),
        ),
      );
      final banner = tester.widget<OrderStatusBanner>(
        find.byType(OrderStatusBanner),
      );
      expect(banner.text, text);
      expect(banner.tone, OrderStatusTone.success);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('with no banner text, no banner renders at all', (tester) async {
    await tester.pumpWidget(gwHost(cardFor('completed')));
    expect(find.byType(OrderStatusBanner), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'the wallet address renders masked by default, reveals on toggle, and re-masks on toggle again',
    (tester) async {
      final order = testOrder(status: 'completed');
      await tester.pumpWidget(gwHost(cardFor('completed')));

      final masked =
          '${order.walletAddress.substring(0, 6)}...${order.walletAddress.substring(order.walletAddress.length - 4)}';
      expect(find.text(masked), findsOneWidget);
      expect(find.text(order.walletAddress), findsNothing);

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();
      expect(find.text(order.walletAddress), findsOneWidget);
      expect(find.text(masked), findsNothing);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();
      expect(find.text(masked), findsOneWidget);
      expect(find.text(order.walletAddress), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'row labels and formatted values are byte-identical to the pre-re-skin card',
    (tester) async {
      final order = testOrder(status: 'completed');
      await tester.pumpWidget(gwHost(cardFor('completed')));

      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Fiat Amount'), findsOneWidget);
      expect(find.text('${order.fiatAmount} ${order.fiat}'), findsOneWidget);
      expect(find.text('Crypto Amount'), findsOneWidget);
      expect(
        find.text('${order.cryptoAmount} ${order.crypto.id}'),
        findsOneWidget,
      );
      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text(order.paymentMethodName), findsOneWidget);
      expect(find.text('Wallet Address'), findsOneWidget);
      expect(find.text('Created At'), findsOneWidget);
      expect(
        find.text(DateFormat.yMd().add_jm().format(order.createdAt.toLocal())),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    "the status text colour differs between a dark host and a light host",
    (tester) async {
      await tester.pumpWidget(gwHost(cardFor('completed'), gw: gwBothModes[0]));
      await tester.pumpAndSettle();
      final darkColor = tester
          .widget<Text>(find.text('completed'))
          .style
          ?.color;

      await tester.pumpWidget(gwHost(cardFor('completed'), gw: gwBothModes[1]));
      await tester.pumpAndSettle();
      final lightColor = tester
          .widget<Text>(find.text('completed'))
          .style
          ?.color;

      expect(darkColor, isNot(equals(lightColor)));
    },
  );
}
