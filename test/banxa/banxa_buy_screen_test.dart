import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/screens/banxa_buy_screen.dart';

import 'gw_pump.dart';

/// Pins 09-08 Task 2/3's re-skin+redesign of `banxa_buy_screen.dart`.
/// `BanxaBuyScreen` builds its own `BlocProvider<MakeOrderCubit>` and
/// `loadCurrencies` wraps its two service calls in a try/catch, so the
/// unreachable Banxa sandbox under `flutter_test` deterministically lands the
/// screen in its error step with empty currency lists — the disabled "Get
/// quote" rung and the currency-load retry affordance, both offline by
/// construction (D-03). The screen also reads the ambient `OrdersCubit` for
/// its orders rail (09-08 Task 3); `fetchOrders` hits the same unreachable
/// sandbox and deterministically lands the rail in its error state too.
///
/// The ENABLED CTA rungs need a live quote/order from the sandbox, which
/// D-03 forbids under automated test; they stay OUTSTANDING and are not
/// asserted here (same posture 09-03 recorded for the pre-09-08 shape).
void main() {
  Widget pumpableBuyScreen() => BlocProvider<OrdersCubit>(
    create: (_) => OrdersCubit(),
    child: const SizedBox(width: 500, height: 900, child: BanxaBuyScreen()),
  );

  Future<void> pumpOffline(WidgetTester tester) async {
    await tester.pumpWidget(gwHost(pumpableBuyScreen()));
    // Let the boot-time `loadCurrencies()`/`fetchOrders()` calls run their
    // course into their caught-error arms. A bare pump() rather than
    // pumpAndSettle(): the boot-loading scrim/spinner in the tree can make
    // pumpAndSettle hang.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('renders without throwing when pumped offline', (tester) async {
    await pumpOffline(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'the CTA is present, labelled Get quote, and disabled with no quote',
    (tester) async {
      await pumpOffline(tester);
      expect(find.text('Get quote'), findsOneWidget);

      // GWButton's InkWell.onTap is null when its onPressed is null — this is
      // the disabled-rung fingerprint, since GWButton has no public "enabled"
      // getter to read directly.
      final inkWell = tester.widget<InkWell>(
        find.ancestor(
          of: find.text('Get quote'),
          matching: find.byType(InkWell),
        ),
      );
      expect(inkWell.onTap, isNull);
    },
  );

  testWidgets(
    'the currency-load retry affordance is present with its Retry tooltip',
    (tester) async {
      await pumpOffline(tester);
      // Unique: the tooltip identifies the currency-retry IconButton. The
      // orders rail's own GWErrorState "Retry" button (offline, same reason)
      // also carries a refresh glyph but no Tooltip, so `find.byIcon` alone
      // would be ambiguous — the tooltip is the disambiguator.
      expect(find.byTooltip('Retry'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byTooltip('Retry'),
          matching: find.byIcon(Icons.refresh),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('no hand-rolled gradient container renders the CTA', (
    tester,
  ) async {
    await pumpOffline(tester);
    // The old CTA was an Ink/BoxDecoration gradient wrapped in an InkWell
    // with no Material ancestor of its own; GWButton always wraps its
    // InkWell in a Material, so this is a structural fingerprint of the
    // re-skin rather than a color check.
    final inkWell = tester.widget<InkWell>(
      find.ancestor(of: find.text('Get quote'), matching: find.byType(InkWell)),
    );
    expect(
      find.ancestor(
        of: find.byWidget(inkWell),
        matching: find.byType(Material),
      ),
      findsWidgets,
    );
  });
}
