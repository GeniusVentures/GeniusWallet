import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/banxa_components/order_status_style.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

import 'gw_pump.dart';

void main() {
  group('orderStatusTone', () {
    test('completed / COMPLETED -> success', () {
      expect(orderStatusTone('completed'), OrderStatusTone.success);
      expect(orderStatusTone('COMPLETED'), OrderStatusTone.success);
    });

    test('pendingpayment / pending / inprogress -> warning', () {
      expect(orderStatusTone('pendingpayment'), OrderStatusTone.warning);
      expect(orderStatusTone('pending'), OrderStatusTone.warning);
      expect(orderStatusTone('inprogress'), OrderStatusTone.warning);
    });

    test('declined / cancelled / expired / failed -> error', () {
      expect(orderStatusTone('declined'), OrderStatusTone.error);
      expect(orderStatusTone('cancelled'), OrderStatusTone.error);
      expect(orderStatusTone('expired'), OrderStatusTone.error);
      expect(orderStatusTone('failed'), OrderStatusTone.error);
    });

    test('unknown / empty -> neutral, never a grey literal fallback', () {
      expect(orderStatusTone('wat'), OrderStatusTone.neutral);
      expect(orderStatusTone(''), OrderStatusTone.neutral);
    });
  });

  group('bannerTone', () {
    test('cancel -> warning', () {
      expect(bannerTone('cancel'), OrderStatusTone.warning);
    });

    test('failure / failed -> error', () {
      expect(bannerTone('failure'), OrderStatusTone.error);
      expect(bannerTone('failed'), OrderStatusTone.error);
    });

    test('success / completed -> success', () {
      expect(bannerTone('success'), OrderStatusTone.success);
      expect(bannerTone('completed'), OrderStatusTone.success);
    });

    test('null -> null', () {
      expect(bannerTone(null), isNull);
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
        gwHost(const OrderStatusPill(status: 'completed'), gw: GWColors.dark()),
      );
      await tester.pumpAndSettle();
      final darkSuccess = tester
          .widget<Text>(find.text('COMPLETED'))
          .style!
          .color;

      await tester.pumpWidget(
        gwHost(const OrderStatusPill(status: 'completed'), gw: GWColors.light()),
      );
      await tester.pumpAndSettle();
      final lightSuccess = tester
          .widget<Text>(find.text('COMPLETED'))
          .style!
          .color;

      expect(darkSuccess, isNotNull);
      expect(lightSuccess, isNotNull);
      expect(darkSuccess, isNot(equals(lightSuccess)));

      await tester.pumpWidget(
        gwHost(const OrderStatusPill(status: 'declined'), gw: GWColors.dark()),
      );
      await tester.pumpAndSettle();
      final darkError = tester
          .widget<Text>(find.text('DECLINED'))
          .style!
          .color;

      await tester.pumpWidget(
        gwHost(const OrderStatusPill(status: 'declined'), gw: GWColors.light()),
      );
      await tester.pumpAndSettle();
      final lightError = tester
          .widget<Text>(find.text('DECLINED'))
          .style!
          .color;

      expect(darkError, isNot(equals(lightError)));
    });

    testWidgets(
      'warning foreground is the same in both hosts (mode-invariant static, '
      'recorded as a fact rather than a defect)',
      (tester) async {
        await tester.pumpWidget(
          gwHost(const OrderStatusPill(status: 'pending'), gw: GWColors.dark()),
        );
        await tester.pumpAndSettle();
        final darkWarning = tester
            .widget<Text>(find.text('PENDING'))
            .style!
            .color;

        await tester.pumpWidget(
          gwHost(
            const OrderStatusPill(status: 'pending'),
            gw: GWColors.light(),
          ),
        );
        await tester.pumpAndSettle();
        final lightWarning = tester
            .widget<Text>(find.text('PENDING'))
            .style!
            .color;

        expect(darkWarning, equals(lightWarning));
      },
    );
  });
}
