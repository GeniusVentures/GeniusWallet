import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/banxa_components/order_status_style.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

import 'gw_pump.dart';

void main() {
  group('orderStatusTone', () {
    test('only complete is success, in any case', () {
      expect(orderStatusTone('complete'), OrderStatusTone.success);
      expect(orderStatusTone('COMPLETE'), OrderStatusTone.success);
    });

    test('every in-flight status is warning', () {
      for (final status in [
        'pendingPayment',
        'waitingPayment',
        'extraVerification',
        'paymentReceived',
        'inProgress',
        'cryptoTransferred',
        'coinTransferred',
      ]) {
        expect(
          orderStatusTone(status),
          OrderStatusTone.warning,
          reason: status,
        );
      }
    });

    test('declined is error', () {
      expect(orderStatusTone('declined'), OrderStatusTone.error);
    });

    test('expired, cancelled and refunded are neutral', () {
      expect(orderStatusTone('expired'), OrderStatusTone.neutral);
      expect(orderStatusTone('cancelled'), OrderStatusTone.neutral);
      expect(orderStatusTone('refunded'), OrderStatusTone.neutral);
    });

    test('unknown, empty and the legacy strings are neutral', () {
      for (final status in ['wat', '', 'completed', 'pending', 'failed']) {
        expect(
          orderStatusTone(status),
          OrderStatusTone.neutral,
          reason: status,
        );
      }
    });
  });

  group('OrderStatusPill live appearance read', () {
    // NB: `MaterialApp` wraps its content in an implicit `AnimatedTheme`
    // (`kThemeAnimationDuration`), so re-pumping with a different `GWColors`
    // host requires `pumpAndSettle()` (not a single `pump()`) before the
    // rendered colour reflects the new theme -- otherwise the assertion
    // reads the mid-interpolation (old) value. This is a test-harness detail,
    // not a defect in `OrderStatusPill` itself (confirmed against a plain
    // `Theme.of(context).extension<GWColors>()` read with no widget
    // involved at all).
    testWidgets('success and error foreground colours differ dark vs light', (
      tester,
    ) async {
      await tester.pumpWidget(
        gwHost(const OrderStatusPill(status: 'complete'), gw: GWColors.dark()),
      );
      await tester.pumpAndSettle();
      final darkSuccess = tester.widget<Text>(find.text('DONE')).style!.color;

      await tester.pumpWidget(
        gwHost(const OrderStatusPill(status: 'complete'), gw: GWColors.light()),
      );
      await tester.pumpAndSettle();
      final lightSuccess = tester.widget<Text>(find.text('DONE')).style!.color;

      expect(darkSuccess, isNotNull);
      expect(lightSuccess, isNotNull);
      expect(darkSuccess, isNot(equals(lightSuccess)));

      await tester.pumpWidget(
        gwHost(const OrderStatusPill(status: 'declined'), gw: GWColors.dark()),
      );
      await tester.pumpAndSettle();
      final darkError = tester
          .widget<Text>(find.text('PAYMENT DECLINED'))
          .style!
          .color;

      await tester.pumpWidget(
        gwHost(const OrderStatusPill(status: 'declined'), gw: GWColors.light()),
      );
      await tester.pumpAndSettle();
      final lightError = tester
          .widget<Text>(find.text('PAYMENT DECLINED'))
          .style!
          .color;

      expect(darkError, isNot(equals(lightError)));
    });

    testWidgets(
      // Was: "warning foreground is the same in both hosts (mode-invariant
      // static, recorded as a fact rather than a defect)". It WAS a defect.
      // The pill painted its label in `statusWarning`, a FILL-tuned token
      // measuring ~1.47:1 against its own wash on a light canvas -- the label
      // was effectively invisible in light mode. Fixed 2026-07-29 by reading
      // `statusWarningText`, so the warning tone now varies by appearance
      // exactly like the error tone asserted directly above.
      'warning foreground differs between hosts, like every other tone',
      (tester) async {
        await tester.pumpWidget(
          gwHost(
            const OrderStatusPill(status: 'pendingPayment'),
            gw: GWColors.dark(),
          ),
        );
        await tester.pumpAndSettle();
        final darkWarning = tester
            .widget<Text>(find.text('WAITING FOR PAYMENT'))
            .style!
            .color;

        await tester.pumpWidget(
          gwHost(
            const OrderStatusPill(status: 'pendingPayment'),
            gw: GWColors.light(),
          ),
        );
        await tester.pumpAndSettle();
        final lightWarning = tester
            .widget<Text>(find.text('WAITING FOR PAYMENT'))
            .style!
            .color;

        expect(darkWarning, isNot(equals(lightWarning)));
      },
    );
  });
}
