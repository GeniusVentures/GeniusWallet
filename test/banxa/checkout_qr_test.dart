import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/banxa_api_services.dart';
import 'package:genius_wallet/banxa/banxa_order/polling_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/polling_order_state.dart';
import 'package:genius_wallet/banxa/checkout_qr.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'gw_pump.dart';

/// A hand-rolled `PollingCubit` subclass that emits a fixed [PollingState] on
/// construction and never starts a timer or hits the network (09-CONTEXT.md
/// D-03) — `CheckoutQrPage` reads a live `PollingCubit` from the tree, so the
/// only compliant substitute is a fake cubit, never a real poll.
class _FakePollingCubit extends PollingCubit {
  _FakePollingCubit(PollingState fixedState)
    : super(orderId: 'ord_0001', api: BanxaApiService()) {
    emit(fixedState);
  }
}

/// Pins 09-05 Task 1's re-skin of `CheckoutQrPage`: the back-arrow AppBar
/// (shared recipe, `Scan to Continue` title), the brand `GWButton` Copy Link
/// CTA, the retyped instruction/URL/status text, and — the one assertion that
/// must survive every future "consistency" pass — the QR's white backing
/// staying the SAME colour in both appearances.
void main() {
  Widget qrPageFor(PollingState state, {GWColors? gw}) => gwHost(
    BlocProvider<PollingCubit>.value(
      value: _FakePollingCubit(state),
      child: const CheckoutQrPage(
        checkoutUrl: 'https://banxa-sandbox.com/checkout/abc123def456',
        orderId: 'ord_0001',
      ),
    ),
    gw: gw,
  );

  testWidgets(
    'renders the instruction copy, the QR, the truncated URL and the Copy Link action',
    (tester) async {
      await tester.pumpWidget(
        qrPageFor(const PollingState(status: PollingStatus.initial)),
      );

      expect(
        find.text('Scan this QR on another device to complete checkout.'),
        findsOneWidget,
      );
      expect(find.byType(QrImageView), findsOneWidget);
      expect(
        find.text('https://banxa-sandbox.com/checkout/abc123def456'),
        findsOneWidget,
      );
      expect(find.text('Copy Link'), findsOneWidget);
      expect(find.text('Scan to Continue'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('the waiting copy renders when the polling state has no message', (
    tester,
  ) async {
    await tester.pumpWidget(
      qrPageFor(const PollingState(status: PollingStatus.loading)),
    );

    expect(find.text('Waiting for payment...'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    "the polling state's own message renders in place of the waiting copy when non-empty",
    (tester) async {
      await tester.pumpWidget(
        qrPageFor(
          const PollingState(
            status: PollingStatus.success,
            message: 'Order status: pendingpayment',
          ),
        ),
      );

      expect(find.text('Order status: pendingpayment'), findsOneWidget);
      expect(find.text('Waiting for payment...'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    "the QR's white backing is the SAME colour across a dark host and a light host",
    (tester) async {
      await tester.pumpWidget(
        qrPageFor(
          const PollingState(status: PollingStatus.initial),
          gw: gwBothModes[0],
        ),
      );
      await tester.pumpAndSettle();
      final darkContainer = tester.widget<Container>(
        find
            .ancestor(
              of: find.byType(QrImageView),
              matching: find.byType(Container),
            )
            .first,
      );

      await tester.pumpWidget(
        qrPageFor(
          const PollingState(status: PollingStatus.initial),
          gw: gwBothModes[1],
        ),
      );
      await tester.pumpAndSettle();
      final lightContainer = tester.widget<Container>(
        find
            .ancestor(
              of: find.byType(QrImageView),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(darkContainer.color, Colors.white);
      expect(lightContainer.color, Colors.white);
      expect(darkContainer.color, equals(lightContainer.color));
      expect(tester.takeException(), isNull);
    },
  );
}
