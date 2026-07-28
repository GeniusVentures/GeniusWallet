import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/banxa_components/quote_card.dart';
import 'package:genius_wallet/banxa/banxa_order/create_order_state.dart';

import 'fixtures.dart';
import 'gw_pump.dart';

/// Pins 09-03 Task 2's re-skin of `QuoteCard` (D-08: this widget has no
/// callers in lib/ — `banxa_buy_screen.dart` renders an equivalent block
/// inline — and Phase 9 re-skinned it anyway, deliberately, without wiring
/// it in). This test file is the only thing that will ever exercise the
/// widget, which is precisely why its four assertions matter.
void main() {
  testWidgets(
    'a quote-bearing state with compact:false renders the full receive wording and both fee lines',
    (tester) async {
      final state = testQuoteState();
      await tester.pumpWidget(gwHost(QuoteCard(state: state, compact: false)));

      expect(
        find.text(
          'You will receive: ${state.quote!.cryptoAmount} ${state.cryptoCode}',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Gateway: ${state.quote!.processingFee} ${state.fiatCode}'),
        findsOneWidget,
      );
      expect(
        find.text('Network: ${state.quote!.networkFee} ${state.fiatCode}'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('with compact:true it renders the short receive wording', (
    tester,
  ) async {
    final state = testQuoteState();
    await tester.pumpWidget(gwHost(QuoteCard(state: state, compact: true)));

    expect(
      find.text('Receive: ${state.quote!.cryptoAmount} ${state.cryptoCode}'),
      findsOneWidget,
    );
    expect(
      find.text(
        'You will receive: ${state.quote!.cryptoAmount} ${state.cryptoCode}',
      ),
      findsNothing,
    );
  });

  testWidgets('with a state carrying no quote, it renders nothing', (
    tester,
  ) async {
    final state = MakeOrderState.initial();
    await tester.pumpWidget(gwHost(QuoteCard(state: state, compact: false)));

    expect(find.byType(QuoteCard), findsOneWidget);
    expect(find.byType(Card), findsNothing);
    expect(find.textContaining('receive'), findsNothing);
  });

  testWidgets(
    "its fee-line text colour differs between a dark host and a light host (live appearance read)",
    (tester) async {
      // gw.textSecondary is the field that genuinely diverges between
      // GWColors.dark()/.light() (light's value is an explicit AA-fix
      // override, not a re-derivation of the same global getter). The
      // receive line's gw.textPrimary is NOT usable for this check: both
      // factories construct it from the same GeniusWalletColors.textPrimary
      // getter, which itself reads a single app-wide appearance flag rather
      // than varying per constructed instance — so dark() and light() both
      // yield the same textPrimary value here, a mode-invariant fact of the
      // token itself, not a defect in this widget's live GWColors read.
      final state = testQuoteState();
      final feeText =
          'Gateway: ${state.quote!.processingFee} ${state.fiatCode}';

      await tester.pumpWidget(
        gwHost(QuoteCard(state: state, compact: false), gw: gwBothModes[0]),
      );
      await tester.pumpAndSettle();
      final darkColor = tester.widget<Text>(find.text(feeText)).style?.color;

      await tester.pumpWidget(
        gwHost(QuoteCard(state: state, compact: false), gw: gwBothModes[1]),
      );
      await tester.pumpAndSettle();
      final lightColor = tester.widget<Text>(find.text(feeText)).style?.color;

      expect(darkColor, isNot(equals(lightColor)));
    },
  );
}
