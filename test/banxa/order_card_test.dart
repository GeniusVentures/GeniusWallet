import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/banxa_components/order_card.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

import 'fixtures.dart';
import 'gw_pump.dart';

/// Pins 09-02 Task 1's re-skin of `OrderCard`: the shared status-pill ladder
/// (09-01's `order_status_style.dart`), the frozen row values/labels (D-01),
/// and the three `GWButton` variants, all inside the real grid tile size
/// (`banxa_orders_history.dart`'s `294.0` divisor / `300.0` `mainAxisExtent`)
/// so a re-skin overflow fails here rather than passing silently.
void main() {
  Widget cardFor(String status) => SizedBox(
    width: 294.0,
    height: 300.0,
    child: OrderCard(
      order: testOrder(status: status),
      onSeeDetails: () {},
      onCompletePayment: () {},
      onRetryOrder: () {},
    ),
  );

  testWidgets('completed order shows a success-toned status pill', (
    tester,
  ) async {
    await tester.pumpWidget(gwHost(cardFor('completed')));
    final gw = GWColors.dark();
    final pillText = tester.widget<Text>(find.text('COMPLETED'));
    expect(pillText.style?.color, gw.statusSuccess);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'pendingpayment order shows a warning-toned pill and a Complete Payment button',
    (tester) async {
      await tester.pumpWidget(gwHost(cardFor('pendingpayment')));
      final pillText = tester.widget<Text>(find.text('PENDINGPAYMENT'));
      expect(pillText.style?.color, GeniusWalletColors.statusWarning);
      expect(find.text('Complete Payment'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'declined order shows an error-toned pill and a non-destructive Retry Order button',
    (tester) async {
      await tester.pumpWidget(gwHost(cardFor('declined')));
      final gw = GWColors.dark();
      final pillText = tester.widget<Text>(find.text('DECLINED'));
      expect(pillText.style?.color, gw.statusError);

      final retryText = tester.widget<Text>(find.text('Retry Order'));
      expect(retryText.style?.color, isNot(equals(gw.statusError)));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'unrecognised status shows a neutral-toned pill and neither status action button',
    (tester) async {
      await tester.pumpWidget(gwHost(cardFor('onhold')));
      final gw = GWColors.dark();
      final pillText = tester.widget<Text>(find.text('ONHOLD'));
      expect(pillText.style?.color, gw.textSecondary);
      expect(find.text('Complete Payment'), findsNothing);
      expect(find.text('Retry Order'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('every card shows a See Details button', (tester) async {
    await tester.pumpWidget(gwHost(cardFor('completed')));
    expect(find.text('See Details'), findsOneWidget);
  });

  testWidgets(
    'row labels and derived fiat/crypto strings are byte-identical to the pre-re-skin card',
    (tester) async {
      final order = testOrder(status: 'completed');
      await tester.pumpWidget(gwHost(cardFor('completed')));

      expect(find.text('Fiat:'), findsOneWidget);
      expect(find.text('${order.fiatAmount} ${order.fiat}'), findsOneWidget);
      expect(find.text('Crypto:'), findsOneWidget);
      expect(
        find.text('${order.cryptoAmount} ${order.crypto.id}'),
        findsOneWidget,
      );
      expect(find.text('Payment:'), findsOneWidget);
      expect(find.text(order.paymentMethodName), findsOneWidget);
      expect(find.text('Created:'), findsOneWidget);
      expect(find.text('Updated:'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    "the status pill's text colour differs between a dark host and a light host",
    (tester) async {
      await tester.pumpWidget(gwHost(cardFor('completed'), gw: gwBothModes[0]));
      await tester.pumpAndSettle();
      final darkColor = tester
          .widget<Text>(find.text('COMPLETED'))
          .style
          ?.color;

      await tester.pumpWidget(gwHost(cardFor('completed'), gw: gwBothModes[1]));
      await tester.pumpAndSettle();
      final lightColor = tester
          .widget<Text>(find.text('COMPLETED'))
          .style
          ?.color;

      expect(darkColor, isNot(equals(lightColor)));
    },
  );
}
