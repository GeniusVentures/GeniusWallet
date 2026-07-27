import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/screens/banxa_buy_screen.dart';

import 'gw_pump.dart';

/// Pins 09-03 Task 1's re-skin of `banxa_buy_screen.dart`. `BanxaBuyScreen`
/// builds its own `BlocProvider` and `MakeOrderCubit.loadCurrencies` wraps
/// its two service calls in a try/catch, so the unreachable Banxa sandbox
/// under `flutter_test` deterministically lands the screen in its error
/// step with empty currency lists — the disabled Create Order rung and the
/// currency-load retry affordance, both offline by construction (D-03).
///
/// The ENABLED Create Order rung needs a live quote from the sandbox, which
/// D-03 forbids under automated test; it stays OUTSTANDING and is not
/// asserted here.
void main() {
  Future<void> pumpOffline(WidgetTester tester) async {
    await tester.pumpWidget(
      gwHost(const SizedBox(width: 500, height: 900, child: BanxaBuyScreen())),
    );
    // Let the boot-time `loadCurrencies()` call run its course into the
    // caught-error arm. A bare pump() rather than pumpAndSettle(): the
    // boot-loading scrim/spinner in the tree can make pumpAndSettle hang.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('renders without throwing when pumped offline', (
    tester,
  ) async {
    await pumpOffline(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the Create Order CTA is present, labelled Create Order, and disabled', (
    tester,
  ) async {
    await pumpOffline(tester);
    expect(find.text('Create Order'), findsOneWidget);

    // GWButton's InkWell.onTap is null when its onPressed is null — this is
    // the disabled-rung fingerprint, since GWButton has no public "enabled"
    // getter to read directly.
    final inkWell = tester.widget<InkWell>(
      find.ancestor(
        of: find.text('Create Order'),
        matching: find.byType(InkWell),
      ),
    );
    expect(inkWell.onTap, isNull);
  });

  testWidgets('the currency-load retry affordance is present with its Retry tooltip', (
    tester,
  ) async {
    await pumpOffline(tester);
    expect(find.byTooltip('Retry'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('the Get Quote control is present and disabled', (
    tester,
  ) async {
    await pumpOffline(tester);
    expect(find.text('Get Quote'), findsOneWidget);

    final inkWell = tester.widget<InkWell>(
      find.ancestor(
        of: find.text('Get Quote'),
        matching: find.byType(InkWell),
      ),
    );
    expect(inkWell.onTap, isNull);
  });

  testWidgets('no hand-rolled gradient container renders the CTA', (
    tester,
  ) async {
    await pumpOffline(tester);
    // The old CTA was an Ink/BoxDecoration gradient wrapped in an InkWell
    // with no Material ancestor of its own; GWButton always wraps its
    // InkWell in a Material, so this is a structural fingerprint of the
    // re-skin rather than a color check.
    final inkWell = tester.widget<InkWell>(
      find.ancestor(
        of: find.text('Create Order'),
        matching: find.byType(InkWell),
      ),
    );
    expect(
      find.ancestor(of: find.byWidget(inkWell), matching: find.byType(Material)),
      findsWidgets,
    );
  });
}
