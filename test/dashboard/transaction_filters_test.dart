import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/dashboard/home/widgets/transactions_slim_view.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// Two checks in one file: the filter PREDICATES (pure unit, most of the file)
/// and the one thing units cannot see — whether the bar FITS the title row.
///
/// The headline test is the coverage loop: sketch 011 found that `swap`,
/// `purchase` and `process` were reachable by NO filter, so those transactions
/// could only ever be found under "All". That is a findability bug, not a
/// styling preference, and this file is what keeps it closed.

Transaction _tx({
  TransactionType? type,
  TransactionStatus status = TransactionStatus.completed,
  TransactionDirection direction = TransactionDirection.sent,
  DateTime? at,
}) {
  return Transaction(
    hash: '0xabc',
    fromAddress: '0x1111',
    recipients: [TransferRecipients(toAddr: '0x2222', amount: '1.0')],
    timeStamp: at ?? DateTime(2026, 7, 22),
    transactionDirection: direction,
    fees: '0.001',
    coinSymbol: 'ETH',
    transactionStatus: status,
    type: type,
  );
}

/// Sets the GLOBAL appearance to [mode] and returns the matching [GWColors],
/// restoring dark (the module-level default) on teardown so no later test file
/// inherits a flipped flag.
///
/// Both halves are required, and that is the point. `GWColors.light()` copies
/// `surfaceMenu` (and the rest) from `GeniusWalletColors.surfaceMenu`, a
/// GLOBAL getter keyed off [GWAppearance] — so constructing a "light" instance
/// while the global is dark hands back DARK values. Every light iteration in
/// this file used to do exactly that, which meant `_activeLabelShader`'s
/// luminance branch took the dark arm in both parameterisations and the light
/// degradation was never painted. Parameterising over [GWAppearanceMode] and
/// building the [GWColors] from the flag is what makes the two agree by
/// construction. Same mechanism as `themeFor` in
/// `test/theme/theme_contrast_test.dart:23-29`.
GWColors gwFor(GWAppearanceMode mode) {
  GWAppearance.instance.value = mode;
  addTearDown(() => GWAppearance.instance.value = GWAppearanceMode.dark);
  return mode == GWAppearanceMode.light ? GWColors.light() : GWColors.dark();
}

void main() {
  group('coverage', () {
    // THE test. Every TransactionType must be findable by some filter other
    // than All.
    for (final type in TransactionType.values) {
      test('$type is reachable by at least one non-all filter', () {
        final tx = _tx(type: type);
        final hits = Filters.values
            .where((f) => f != Filters.all && f.matches(tx))
            .toList();
        expect(
          hits,
          isNotEmpty,
          reason: '$type is findable only under All — the sketch-011 bug',
        );
      });
    }

    test('the two non-happy-path statuses are reachable too', () {
      expect(
        Filters.pending.matches(_tx(status: TransactionStatus.pending)),
        isTrue,
      );
      expect(
        Filters.failed.matches(_tx(status: TransactionStatus.failed)),
        isTrue,
      );
    });
  });

  group('matches', () {
    test('escrow spans BOTH escrow and escrowRelease', () {
      expect(Filters.escrow.matches(_tx(type: TransactionType.escrow)), isTrue);
      expect(
        Filters.escrow.matches(_tx(type: TransactionType.escrowRelease)),
        isTrue,
      );
      expect(Filters.escrow.matches(_tx(type: TransactionType.swap)), isFalse);
    });

    test('failed spans BOTH failed and cancelled', () {
      expect(
        Filters.failed.matches(_tx(status: TransactionStatus.failed)),
        isTrue,
      );
      expect(
        Filters.failed.matches(_tx(status: TransactionStatus.cancelled)),
        isTrue,
      );
      expect(
        Filters.failed.matches(_tx(status: TransactionStatus.completed)),
        isFalse,
      );
    });

    test('jobs maps to the process type', () {
      expect(Filters.jobs.matches(_tx(type: TransactionType.process)), isTrue);
      expect(Filters.jobs.matches(_tx(type: TransactionType.mint)), isFalse);
    });

    test('direction filters read the direction, not the type', () {
      final sent = _tx(direction: TransactionDirection.sent);
      final received = _tx(direction: TransactionDirection.received);
      expect(Filters.sent.matches(sent), isTrue);
      expect(Filters.sent.matches(received), isFalse);
      expect(Filters.received.matches(received), isTrue);
    });

    test('all matches anything, including a null type', () {
      expect(Filters.all.matches(_tx()), isTrue);
      expect(Filters.all.matches(_tx(type: TransactionType.transfer)), isTrue);
    });
  });

  group('UI groupings', () {
    test('no filter is orphaned from a UI group', () {
      final grouped = {
        ...Filters.primary,
        ...Filters.overflowTypes,
        ...Filters.overflowStatuses,
      };
      final expected = Filters.values.toSet()..remove(Filters.all);
      expect(
        grouped,
        equals(expected),
        reason: 'a filter in no group is unreachable in the UI',
      );
    });

    test('the primary row order is locked by the ROADMAP', () {
      expect(
        Filters.primary,
        orderedEquals([
          Filters.sent,
          Filters.received,
          Filters.mint,
          Filters.jobs,
        ]),
      );
    });

    test('isInOverflow is true for menu filters and false for row chips', () {
      for (final f in Filters.primary) {
        expect(Filters.isInOverflow(f), isFalse, reason: f.label);
      }
      for (final f in [...Filters.overflowTypes, ...Filters.overflowStatuses]) {
        expect(Filters.isInOverflow(f), isTrue, reason: f.label);
      }
      expect(Filters.isInOverflow(Filters.all), isFalse);
    });

    test('every chip-bearing filter has a badge kind; all has none', () {
      expect(Filters.all.badgeKind, isNull);
      for (final f in Filters.values.where((f) => f != Filters.all)) {
        expect(f.badgeKind, isNotNull, reason: '${f.label} has no glyph');
      }
    });
  });

  group('filterCounts', () {
    final txs = [
      _tx(type: TransactionType.transfer, direction: TransactionDirection.sent),
      _tx(type: TransactionType.swap, direction: TransactionDirection.sent),
      _tx(type: TransactionType.mint, direction: TransactionDirection.received),
      _tx(type: TransactionType.escrow),
      _tx(type: TransactionType.escrowRelease),
      _tx(type: TransactionType.process, status: TransactionStatus.pending),
      _tx(type: TransactionType.purchase, status: TransactionStatus.failed),
      _tx(type: TransactionType.transfer, status: TransactionStatus.cancelled),
    ];
    final counts = filterCounts(txs);

    test('sent/received count PLAIN TRANSFERS only, not every direction', () {
      // The fixture has 6 outgoing non-transfers (swap, escrow, escrowRelease,
      // process, purchase) alongside 2 outgoing transfers. Matching on
      // direction alone counted 7 here and made "Sent" a bucket for
      // everything that left the wallet, so the type filters stopped being
      // categories. These two numbers are the regression guard.
      expect(counts[Filters.sent], 2);
      expect(counts[Filters.received], 0);
    });

    test('every transaction lands in exactly one TYPE filter', () {
      const typeFilters = [
        Filters.sent,
        Filters.received,
        Filters.mint,
        Filters.jobs,
        Filters.escrow,
        Filters.swap,
        Filters.purchase,
      ];
      for (final tx in txs) {
        final hits = typeFilters.where((f) => f.matches(tx)).toList();
        expect(
          hits.length,
          1,
          reason:
              '${tx.type} / ${tx.transactionDirection} matched '
              '${hits.map((f) => f.label).join(", ")} — a transaction must '
              'belong to exactly one type category. Status filters (pending, '
              'failed) are deliberately orthogonal and excluded here.',
        );
      }
    });

    test('escrow counts both escrow types', () {
      expect(counts[Filters.escrow], 2);
    });

    test('failed counts both failed and cancelled', () {
      expect(counts[Filters.failed], 2);
    });

    test('pending and the single-type filters', () {
      expect(counts[Filters.pending], 1);
      expect(counts[Filters.jobs], 1);
      expect(counts[Filters.swap], 1);
      expect(counts[Filters.purchase], 1);
      expect(counts[Filters.mint], 1);
    });

    test('all is excluded — it has no chip and no count to show', () {
      expect(counts.containsKey(Filters.all), isFalse);
      expect(counts.length, Filters.values.length - 1);
    });

    test('an empty list yields zeroes, not missing keys', () {
      final empty = filterCounts([]);
      expect(empty[Filters.sent], 0);
      expect(empty.length, Filters.values.length - 1);
    });
  });

  // TX-11. The shipped app printed the SAME copy for "this wallet has never
  // transacted" and "this filter matched nothing", so the second read as a
  // broken load. These are the assertions that stop a future edit collapsing
  // the two back into one.
  group('empty-state copy', () {
    test('the filtered title names the filter', () {
      expect(filteredEmptyTitle(Filters.swap), 'No swapped transactions');
      expect(filteredEmptyTitle(Filters.pending), 'No pending transactions');
      expect(filteredEmptyTitle(Filters.jobs), 'No computing transactions');
    });

    test(
      'the filtered message states how many DO exist, and agrees in number',
      () {
        expect(filteredEmptyMessage(1), contains('You have 1 transaction,'));
        expect(filteredEmptyMessage(1), isNot(contains('transactions')));
        expect(filteredEmptyMessage(8), contains('You have 8 transactions,'));
      },
    );

    test('the two empty states are never the same words', () {
      for (final f in Filters.values.where((f) => f != Filters.all)) {
        expect(
          filteredEmptyTitle(f),
          isNot(emptyTransactionsTitle),
          reason: '${f.label} filtered-empty reads as an empty wallet',
        );
      }
      expect(filteredEmptyMessage(8), isNot(emptyTransactionsMessage));
    });

    test('the filtered copy does not tell the user to buy anything', () {
      // "Buy GNUS" was the shipped action on a state that is not an empty
      // wallet. The filtered branch offers "Show all" instead.
      expect(filteredEmptyMessage(8).toLowerCase(), isNot(contains('buy')));
      for (final f in Filters.values.where((f) => f != Filters.all)) {
        expect(filteredEmptyTitle(f).toLowerCase(), isNot(contains('buy')));
      }
    });
  });

  // TX-08 / TX-10. The body is a hand-flattened [day header, row, divider, …]
  // list, and the one rule that is easy to get wrong is that a day BOUNDARY
  // carries no divider — the next header is the separator there, so a rule as
  // well would double it. Counting Dividers is what pins that.
  group('day-grouped body', () {
    final now = DateTime.now();
    // 10:00 on a given day: far enough from both midnights that no local
    // timezone or DST offset can move these onto a neighbouring date.
    DateTime dayAt(int daysAgo) =>
        DateTime(now.year, now.month, now.day - daysAgo, 10);

    // Tall enough that ListView.builder materialises every entry, so the
    // Divider count below is the whole list and not just the visible window.
    Widget host(List<Transaction> txs) => MaterialApp(
      theme: ThemeData(extensions: [GWColors.dark()]),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 900,
            height: 1400,
            child: TransactionsSlimView(transactions: txs),
          ),
        ),
      ),
    );

    testWidgets('one row per day: three headers, no boundary dividers', (
      tester,
    ) async {
      await tester.pumpWidget(
        host([_tx(at: dayAt(0)), _tx(at: dayAt(1)), _tx(at: dayAt(3))]),
      );

      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('YESTERDAY'), findsOneWidget);
      // Every day has exactly one row, so there is no WITHIN-day divider —
      // and there is no header rule either: sketch 019 variant B removed it so
      // this panel goes straight from GWSectionTitle to its list, exactly like
      // Assets and Markets. Zero is the correct count; if this ever reads 1
      // again, the header rule has been reintroduced.
      expect(find.byType(Divider), findsNothing);
      // No footer count any more — removed on the 023 walk, both the panel
      // footer and the rail summary. RED if a "N transactions" line returns.
      expect(find.textContaining(RegExp(r'\d+ transactions')), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the gap ABOVE a day label exceeds the row-to-row gap', (
      tester,
    ) async {
      // The RULE, not the pixel values. Measures the WHITESPACE above the day
      // label — last row's bottom to the label's top — because comparing
      // row-to-row distances instead would pass trivially: the label has
      // intrinsic height, so it always pushes the next row further down even
      // with zero padding. This assertion is only meaningful because it
      // isolates the padding itself.
      await tester.pumpWidget(
        host([_tx(at: dayAt(0)), _tx(at: dayAt(0)), _tx(at: dayAt(1))]),
      );

      final rows = find.byType(TransactionRow);
      expect(tester.widgetList(rows).length, 3);

      // Two rows share Today, so this is the WITHIN-day gap.
      final withinDay =
          tester.getRect(rows.at(1)).top - tester.getRect(rows.at(0)).bottom;
      // Second row's bottom up to the YESTERDAY label — pure padding.
      final aboveLabel =
          tester.getRect(find.text('YESTERDAY')).top -
          tester.getRect(rows.at(1)).bottom;

      expect(
        aboveLabel,
        greaterThan(withinDay),
        reason:
            'the space above a day label ($aboveLabel) must exceed the gap '
            'between two rows of the same day ($withinDay) — at space8 these '
            'measured the same and day blocks did not read as separated',
      );
    });

    testWidgets('rows inside one day are separated, the day itself is not', (
      tester,
    ) async {
      await tester.pumpWidget(
        host([_tx(at: dayAt(0)), _tx(at: dayAt(0)), _tx(at: dayAt(1))]),
      );

      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('YESTERDAY'), findsOneWidget);
      // header rule + exactly ONE divider between the two Today rows. The
      // Today→Yesterday boundary contributes none.
      // One WITHIN-day divider (the two Today rows) and nothing else — no
      // header rule, no divider at the day boundary.
      expect(find.byType(Divider), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a single row shows no footer count', (tester) async {
      await tester.pumpWidget(host([_tx(at: dayAt(0))]));
      // The footer was removed on the 023 walk. A single row has nothing to
      // separate either, so no Divider (sketch 019 variant B).
      expect(find.textContaining(RegExp(r'\d+ transaction')), findsNothing);
      expect(find.byType(Divider), findsNothing);
    });
  });

  // The bar lives in GWSectionTitle's trailing slot beside an unwrapped title
  // Text, and the `FittedBox(scaleDown)` that used to absorb overflow is gone
  // (it derives a continuous scale — the 37639d5 freeze class). So the ONLY
  // thing keeping the title row from a RenderFlex overflow is that the bar is
  // narrow enough on its own. That is what this group measures.
  group('bar fits the title row', () {
    final barFinder = find.byWidgetPredicate(
      (w) => w.runtimeType.toString() == '_TransactionFilterBar',
    );

    // EXACTLY ONE ROW by default, and it must be escrow.
    //
    // This host used to pump an EMPTY list, for a reason that was sound: no
    // rows means no coin assets to decode and no row action chip printing
    // "Sent" to collide with the chip label the tests below search for. But an
    // empty scope now hides the bar entirely, so the fixture needs the minimum
    // that makes the scope non-empty — one row.
    //
    // `escrow` is that row because it prints "Escrow locked" (the action chip)
    // and "Locked in escrow" (the subtitle), neither of which collides with
    // `find.text('Sent')` in the two icon-only tests. `_tx`'s other strings are
    // already short — `coinSymbol: 'ETH'`, `hash: '0xabc'` — which matters at
    // 419px, where the harness's fallback font draws one em per character.
    //
    // [txs] is an override, not a second fixture: the two tests that need an
    // EMPTY wallet pass it explicitly, so "empty" can never be the accidental
    // default again.
    Widget host(double width, GWColors gw, [List<Transaction>? txs]) =>
        MaterialApp(
          theme: ThemeData(extensions: [gw]),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: width,
                height: 600,
                child: TransactionsSlimView(
                  transactions: txs ?? [_tx(type: TransactionType.escrow)],
                ),
              ),
            ),
          ),
        );

    for (final mode in GWAppearanceMode.values) {
      // 419/420 straddle the compact threshold; 900 is the /transactions
      // route. 320 is NOT in this list, and the reason matters: the test
      // environment's fallback font draws one em per character, so
      // "Transactions" measures 213.6px here against roughly 110 in real
      // Inter. Everything below ~409 therefore overflows in the harness for a
      // reason that does not exist on screen. The number that IS
      // font-independent — and the one real headroom depends on — is the bar's
      // own width, pinned below at every width.
      for (final width in <double>[419, 420, 900]) {
        testWidgets('${width.toInt()}px (${mode.name})', (tester) async {
          await tester.pumpWidget(host(width, gwFor(mode)));
          expect(tester.takeException(), isNull);

          final bar = tester.getSize(barFinder);
          // 32 chip + 2*space2 shell pad + 2*1 border.
          // 40 = 32px chip + 3px track padding + 1px border, each side —
          // the SAME arithmetic as the chart's _TimeframeSegment, and the
          // 40px the navbar normalizes every interactive control to. If this
          // drifts, the two dashboard controls have stopped matching.
          expect(bar.height, 40);
          // Icon-only at EVERY width, selected or not: four 32px chips + the
          // three 2px inter-chip gaps that match _TimeframeSegment + space2 +
          // 1px rule + space2 + 32px trigger + the 3px/1px shell.
          // Widening this is what eats the title row's headroom, so it is
          // pinned rather than bounded.
          expect(bar.width, 183);
        });
      }
    }

    // The branch SELECTION, not just the copy: `scoped.isEmpty` picks the
    // never-transacted state and `txs.isEmpty` picks the filtered one. Getting
    // this backwards is how the two collapse back into one on screen even
    // while the copy helpers above still pass.
    testWidgets('an empty wallet and an empty filter render differently', (
      tester,
    ) async {
      await tester.pumpWidget(host(900, GWColors.dark(), const []));
      expect(find.text(emptyTransactionsTitle), findsOneWidget);
      expect(find.text('Show all'), findsNothing);
      // Sketch 022's glyph — two opposed arrows, not the receipt this shipped
      // with. Reverting the icon reddens here.
      expect(find.byIcon(Icons.sync_alt), findsOneWidget);

      // One SENT transfer, then filter to Received: history exists, this
      // filter matched none of it.
      await tester.pumpWidget(
        host(900, GWColors.dark(), [_tx(type: TransactionType.transfer)]),
      );
      await tester.tap(find.byTooltip('Received'));
      await tester.pumpAndSettle();

      expect(find.text(emptyTransactionsTitle), findsNothing);
      expect(find.text(filteredEmptyTitle(Filters.received)), findsOneWidget);
      expect(find.text(filteredEmptyMessage(1)), findsOneWidget);

      // And "Show all" is a real way out, not decoration.
      await tester.tap(find.text('Show all'));
      await tester.pumpAndSettle();
      expect(find.text('Show all'), findsNothing);
      // Back to the unfiltered list: the one row returns and the empty state
      // is gone. (No footer count to assert any more — removed on the walk.)
      expect(find.byType(TransactionRow), findsOneWidget);
      expect(find.text(emptyTransactionsTitle), findsNothing);
      expect(tester.takeException(), isNull);
    });

    // TT-05, and the PAIR is the assertion: absent-then-present is what proves
    // the control is bound to the scope rather than merely missing by accident.
    //
    // Goes red if the `scoped.isEmpty ? null :` guard on GWSectionTitle's
    // trailing is removed — or if it is written against `txs`, which is empty
    // here too and so would hide the bar for the wrong reason.
    testWidgets('an empty wallet offers no filter control at all', (
      tester,
    ) async {
      await tester.pumpWidget(host(900, GWColors.dark(), const []));

      // Hidden ENTIRELY, not dimmed: neither the chips nor the `⋯` trigger.
      expect(barFinder, findsNothing);
      expect(find.byTooltip('More filters'), findsNothing);
      expect(find.text(emptyTransactionsTitle), findsOneWidget);

      // One row is all it takes to earn the control back.
      await tester.pumpWidget(
        host(900, GWColors.dark(), [_tx(type: TransactionType.escrow)]),
      );
      await tester.pumpAndSettle();
      expect(barFinder, findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // T-15-07, the inverse guard — and the one that catches the most likely
    // WRONG fix. A filtered-empty wallet is NOT an empty wallet: it has
    // history, the user simply picked a filter with no hits, so the control
    // must survive or they are stranded with no route back to All.
    //
    // Goes red if the guard is written against `txs.isEmpty`.
    testWidgets('the filtered-empty branch keeps its way out', (tester) async {
      await tester.pumpWidget(
        host(900, GWColors.dark(), [_tx(type: TransactionType.transfer)]),
      );
      await tester.tap(find.byTooltip('Received'));
      await tester.pumpAndSettle();

      expect(barFinder, findsOneWidget);
      expect(find.text('Show all'), findsOneWidget);
      // And it must not have collapsed into the never-transacted copy.
      expect(find.text(emptyTransactionsTitle), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('wide: the active chip stays icon-only too', (tester) async {
      // The chip is icon-only in EVERY state at EVERY width — the active one
      // is marked by its gradient fill alone. Selecting a filter must not
      // reveal a label, because a chip that grows on tap shoves its
      // neighbours sideways under the cursor. The tooltip carries the name.
      await tester.pumpWidget(host(900, GWColors.dark()));
      final before = tester.getSize(barFinder).width;

      await tester.tap(find.byTooltip('Sent'));
      await tester.pumpAndSettle();

      expect(find.text('Sent'), findsNothing);
      expect(tester.takeException(), isNull);
      // Selecting changes no width at all — this is the assertion that fails
      // if the expand-to-label animation is ever reintroduced.
      expect(tester.getSize(barFinder).width, before);
      expect(tester.getSize(barFinder).width, lessThan(300));
    });

    testWidgets('compact: the active chip stays icon-only', (tester) async {
      // 419 is one pixel under the compact threshold — and the narrowest the
      // harness's oversized title font allows without a false overflow.
      await tester.pumpWidget(host(419, GWColors.dark()));
      await tester.tap(find.byTooltip('Sent'));
      await tester.pumpAndSettle();

      expect(find.text('Sent'), findsNothing);
      expect(tester.takeException(), isNull);
      // Same 183 as the resting bar: selecting changes no geometry at all.
      expect(tester.getSize(barFinder).width, 183);
    });

    // Run in both appearances: the selected menu label goes through a
    // ShaderMask whose stops differ per appearance (see _activeLabelShader —
    // brandCta's own stops are 1.65:1 and 2.28:1 as light-mode text), so both
    // branches need to have actually been painted at least once. `gwFor` is
    // what makes that true rather than nominal — see its doc comment.
    for (final mode in GWAppearanceMode.values) {
      testWidgets(
        'an overflow filter marks the trigger, never nothing (${mode.name})',
        (tester) async {
          await tester.pumpWidget(host(900, gwFor(mode)));
          expect(find.byTooltip('More filters'), findsOneWidget);

          await tester.tap(find.byTooltip('More filters'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Swapped'));
          await tester.pumpAndSettle();

          // T-12-11: a filter chosen from the menu leaves no chip on the title
          // row, so the trigger itself must carry the state or a partial list
          // reads as a complete one.
          expect(find.byTooltip('Filtered: Swapped'), findsOneWidget);
          expect(find.byTooltip('More filters'), findsNothing);

          // And the menu still renders with that filter selected — the
          // gradient-label branch.
          await tester.tap(find.byTooltip('Filtered: Swapped'));
          await tester.pumpAndSettle();
          expect(find.text('Swapped'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
