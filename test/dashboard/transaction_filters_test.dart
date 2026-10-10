import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/components/cards/gw_select_row.dart';
import 'package:genius_wallet/components/cards/gw_view_all_link.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/dashboard/home/widgets/transactions_slim_view.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// The filter predicates, plus the phone page's header funnel and drawer.
/// The headline is the coverage loop: every transaction type must be
/// reachable by some filter other than "All".

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

    test('every non-happy-path status is reachable from some filter', () {
      // Iterating the enum, not a written-out pair: a status nobody can
      // filter to is a transaction the user cannot find, and the next value
      // added must not be able to slip through this silently.
      for (final status in TransactionStatus.values) {
        if (status == TransactionStatus.completed) {
          continue;
        }
        final reachable = Filters.values
            .where((f) => f != Filters.all)
            .any((f) => f.matches(_tx(status: status)));
        expect(reachable, isTrue, reason: '$status is unreachable');
      }
    });

    test('the three moved-money states fold into the failed finder', () {
      // Membership is a FINDING AID, not a verdict on the money — each row
      // still says what actually happened.
      for (final status in [
        TransactionStatus.needsGas,
        TransactionStatus.partialSuccess,
        TransactionStatus.refunded,
      ]) {
        expect(
          Filters.failed.matches(_tx(status: status)),
          isTrue,
          reason: '$status cannot be found',
        );
      }
    });

    test('a swap in any of the three still lists under the swap filter', () {
      for (final status in [
        TransactionStatus.needsGas,
        TransactionStatus.partialSuccess,
        TransactionStatus.refunded,
      ]) {
        expect(
          Filters.swap.matches(_tx(type: TransactionType.swap, status: status)),
          isTrue,
          reason: '$status vanished from the swap filter',
        );
      }
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
          Filters.purchase,
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
      // Buy orders never reaches this branch: its empty state is the one
      // place that does offer to buy.
      for (final f in Filters.values.where(
        (f) => f != Filters.all && f != Filters.purchase,
      )) {
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

    testWidgets('one row per day: a divider at each day boundary', (
      tester,
    ) async {
      await tester.pumpWidget(
        host([_tx(at: dayAt(0)), _tx(at: dayAt(1)), _tx(at: dayAt(3))]),
      );

      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('YESTERDAY'), findsOneWidget);
      // A rule after every row but the last, day boundaries included, and
      // still no header rule under GWSectionTitle: 3 rows, 2 dividers.
      expect(find.byType(Divider), findsNWidgets(2));
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

    testWidgets('rows are separated within and across days', (tester) async {
      await tester.pumpWidget(
        host([_tx(at: dayAt(0)), _tx(at: dayAt(0)), _tx(at: dayAt(1))]),
      );

      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('YESTERDAY'), findsOneWidget);
      // One between the two Today rows, one at the Today→Yesterday boundary,
      // none after the last row and no header rule.
      expect(find.byType(Divider), findsNWidgets(2));
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

  // The phone page's filter control, as sketch 195 scheme G2 rebuilt it: the
  // trigger left the card for `GWPageHeader.trailing`, the picker became the
  // app's own drawer, and the live filter is named on a dismissible chip above
  // the list.
  //
  // **This group replaces `bar fits the title row`.** That group measured
  // `_TransactionFilterBar` on this same surface - the narrow `page: true`
  // branch - which was the bar's last live call site; this change removed that
  // call, so those pixel pins (52 x 289) now have nothing to measure. The bar
  // itself is still in the file, referenced only from a dead arm in `_panel`;
  // see that method's doc comment.
  //
  // What the pins protected is not lost, it moved: the 44pt touch target is
  // asserted on the trigger below, and the "a live filter must never be
  // invisible" rule the `⋯` menu introduced is asserted twice - on the trigger's
  // tooltip and on the chip row.
  group('the phone page filter control', () {
    /// Four transactions across three filters, so `Escrow` is a real subset
    /// (2 of 4). None of the labels collides with a row's own copy the way
    /// `Sent` does.
    List<Transaction> some() => [
      _tx(type: TransactionType.escrow),
      _tx(type: TransactionType.escrow),
      _tx(type: TransactionType.mint),
      _tx(type: TransactionType.swap),
    ];

    /// A real phone surface: the narrow page branch and the bottom-sheet drawer
    /// both key off screen size, so the default 800x600 would silently test the
    /// wide page and the desktop drawer.
    void surface(WidgetTester tester) {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    Widget host(List<Transaction> txs, [GWColors? gw]) => MaterialApp(
      theme: ThemeData(extensions: [gw ?? GWColors.dark()]),
      home: Scaffold(body: _PhonePage(txs: txs)),
    );

    /// The drawer's own rows, so a `find.text` cannot match the page behind the
    /// sheet - which is still mounted while the sheet is up.
    Finder drawerRow(String label) => find.descendant(
      of: find.byType(GWSelectRow),
      matching: find.text(label),
    );

    // TT-05, and the PAIR is the assertion: absent-then-present is what proves
    // the control is bound to the scope rather than merely missing by accident.
    //
    // 15-03's rule, carried onto the header: a control that filters an empty
    // set is an offer the app cannot honour, and here it would sit directly
    // above the "no transactions yet" block.
    testWidgets('an empty wallet offers no filter control at all', (
      tester,
    ) async {
      surface(tester);
      await tester.pumpWidget(host(const []));
      await tester.pumpAndSettle();

      expect(find.byType(TransactionsFilterTrigger), findsOneWidget);
      // Mounted but drawing nothing - the widget is what the page hands the
      // header, so the assertion has to be on what it PAINTS.
      expect(find.byIcon(Icons.filter_alt_outlined), findsNothing);
      expect(find.text(emptyTransactionsTitle), findsOneWidget);

      // One row is all it takes to earn the control back.
      await tester.pumpWidget(host([_tx(type: TransactionType.escrow)]));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.filter_alt_outlined), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the trigger is a 44x44 target', (tester) async {
      surface(tester);
      await tester.pumpWidget(host(some()));
      await tester.pumpAndSettle();

      // 44 on both axes - Apple's minimum. The header row this sits in is
      // already 44 tall because Buy GNUS (`GWButtonSize.sm`) shares it, so the
      // funnel costs the page no height; `transactions_page_frame_test.dart`
      // measures that on the real page. The GLYPH is 22.
      expect(
        tester.getSize(find.byType(TransactionsFilterTrigger)),
        const Size(44, 44),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('the drawer offers every filter, nothing behind an overflow', (
      tester,
    ) async {
      surface(tester);
      await tester.pumpWidget(host(some()));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Filter transactions'));
      await tester.pumpAndSettle();

      // The drawer is `ResponsiveDrawer`'s, with the header Jakub asked for.
      expect(find.text('Filter'), findsOneWidget);
      // Ten rows: All plus the nine identities, Buy orders among them. The `⋯`
      // menu exists only because a 376px dashboard panel cannot show nine
      // filters; a full-width sheet can, so nothing hides here.
      expect(find.byType(GWSelectRow), findsNWidgets(Filters.values.length));
      for (final f in Filters.values) {
        expect(
          drawerRow(f.label),
          findsOneWidget,
          reason: '${f.name} is a row',
        );
      }
      expect(drawerRow('Buy orders'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // Run in BOTH appearances: the drawer's selected row paints a ShaderMask
    // and a gradient tint, and light is where this repo has historically
    // broken. `gwFor` is what makes the light iteration genuinely light - see
    // its doc comment.
    for (final mode in GWAppearanceMode.values) {
      testWidgets('picking a filter filters the list and names it (${mode.name})', (
        tester,
      ) async {
        surface(tester);
        await tester.pumpWidget(host(some(), gwFor(mode)));
        await tester.pumpAndSettle();

        expect(find.byType(TransactionRow), findsNWidgets(4));

        await tester.tap(find.byTooltip('Filter transactions'));
        await tester.pumpAndSettle();
        await tester.tap(drawerRow('Escrow'));
        await tester.pumpAndSettle();

        // The drawer closed itself, the list filtered, and - the whole point of
        // the chip row - the page SAYS which filter is on and by how much. With
        // the trigger off the card, this is the only thing on screen naming it.
        expect(find.text('Filter'), findsNothing);
        expect(find.byType(TransactionRow), findsNWidgets(2));
        expect(find.text('Escrow'), findsOneWidget);
        // GWKicker upper-cases its own label, and the shape is Assets'
        // (`3 of 11 assets`) minus the noun the chip already carries.
        expect(find.text('2 OF 4'), findsOneWidget);
        // And the trigger is marked, so a partial list can never read as a
        // complete one - the `⋯` trigger's own defect, carried forward.
        expect(find.byTooltip('Filtered: Escrow'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    // A live filter paints the funnel and rings the chip in
    // `brandPrimaryOnSurface`: brand as FOREGROUND, a non-text mark, so 3:1
    // (WCAG 1.4.11) against the page canvas. The chip's name is text, so 4.5:1.
    for (final mode in GWAppearanceMode.values) {
      test(
        'the live-filter marks clear contrast on the canvas (${mode.name})',
        () {
          final gw = gwFor(mode);
          expect(
            _contrastRatio(gw.brandPrimaryOnSurface, gw.surfaceBase),
            greaterThanOrEqualTo(3),
            reason: 'funnel glyph and chip edge, non-text',
          );
          expect(
            _contrastRatio(gw.textPrimary, gw.surfaceBase),
            greaterThanOrEqualTo(4.5),
            reason: 'chip label, text',
          );
        },
      );
    }

    testWidgets('the chip drops the filter without opening anything', (
      tester,
    ) async {
      surface(tester);
      await tester.pumpWidget(host(some()));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Filter transactions'));
      await tester.pumpAndSettle();
      await tester.tap(drawerRow('Escrow'));
      await tester.pumpAndSettle();
      expect(find.byType(TransactionRow), findsNWidgets(2));

      await tester.tap(find.byTooltip('Clear filter'));
      await tester.pumpAndSettle();

      // Back to unfiltered, and the chip row is GONE rather than emptied - it
      // costs 0px idle, which is what let the permanent count line be dropped.
      expect(find.byType(TransactionRow), findsNWidgets(4));
      expect(find.byTooltip('Clear filter'), findsNothing);
      expect(find.text('2 OF 4'), findsNothing);
      expect(find.byTooltip('Filter transactions'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // The branch SELECTION, not just the copy: `scoped.isEmpty` picks the
    // never-transacted state and `txs.isEmpty` picks the filtered one. Getting
    // this backwards is how the two collapse back into one on screen even
    // while the copy helpers above still pass.
    testWidgets('an empty wallet and an empty filter render differently', (
      tester,
    ) async {
      surface(tester);
      await tester.pumpWidget(host(const []));
      await tester.pumpAndSettle();
      expect(find.text(emptyTransactionsTitle), findsOneWidget);
      expect(find.text('Show all'), findsNothing);
      // Sketch 022's glyph — two opposed arrows, not the receipt this shipped
      // with. Reverting the icon reddens here.
      expect(find.byIcon(Icons.sync_alt), findsOneWidget);

      // History exists; `Received` matches none of it.
      await tester.pumpWidget(host(some()));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Filter transactions'));
      await tester.pumpAndSettle();
      await tester.tap(drawerRow('Received'));
      await tester.pumpAndSettle();

      expect(find.text(emptyTransactionsTitle), findsNothing);
      expect(find.text(filteredEmptyTitle(Filters.received)), findsOneWidget);
      expect(find.text(filteredEmptyMessage(4)), findsOneWidget);

      // And "Show all" is a real way out, not decoration.
      await tester.tap(find.text('Show all'));
      await tester.pumpAndSettle();
      expect(find.text('Show all'), findsNothing);
      expect(find.byType(TransactionRow), findsNWidgets(4));
      expect(tester.takeException(), isNull);
    });

    // T-15-07, the inverse guard - and the one that catches the most likely
    // WRONG fix. A filtered-empty wallet is NOT an empty wallet: it has
    // history, the user simply picked a filter with no hits, so BOTH ways back
    // must survive or they are stranded.
    //
    // Goes red if either guard is written against `txs.isEmpty`.
    testWidgets('the filtered-empty branch keeps both ways out', (
      tester,
    ) async {
      surface(tester);
      await tester.pumpWidget(host(some()));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Filter transactions'));
      await tester.pumpAndSettle();
      await tester.tap(drawerRow('Received'));
      await tester.pumpAndSettle();

      // The trigger, the chip's dismiss, and the empty state's own action.
      expect(find.byTooltip('Filtered: Received'), findsOneWidget);
      expect(find.byTooltip('Clear filter'), findsOneWidget);
      expect(find.text('Show all'), findsOneWidget);
      expect(find.text(emptyTransactionsTitle), findsNothing);
      expect(tester.takeException(), isNull);
    });

    // Phase 25's half of the move, and the half no other test covers: the bar
    // did not just get a new home, it LEFT the dashboard panel. Asserting both
    // halves in one test is what makes it a move rather than two independent
    // facts that could drift into "neither surface has a filter" or "both do".
    //
    // Goes red if the trailing is written unconditionally, in either direction.
    testWidgets('the dashboard panel shows a View all and no filter at all', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [GWColors.dark()]),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 700,
                height: 600,
                // `page: false` is the DASHBOARD panel, and it passes neither
                // `selectedFilter` nor `onFilterChanged` - exactly the call
                // `dashboard_screen.dart` makes. That is the additive half of
                // 195's state lift: the panel keeps its own internal filter
                // with no call-site edit.
                child: TransactionsSlimView(
                  transactions: [_tx(type: TransactionType.escrow)],
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == '_TransactionFilterBar',
        ),
        findsNothing,
      );
      expect(find.byIcon(Icons.filter_alt_outlined), findsNothing);
      expect(find.byType(GWViewAllLink), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

/// The header trigger and the list as `TransactionsScreen` wires them, sharing
/// ONE filter. They are separate widgets, so pumping `TransactionsSlimView`
/// alone cannot reach a filter at all.
class _PhonePage extends StatefulWidget {
  const _PhonePage({required this.txs});

  final List<Transaction> txs;

  @override
  State<_PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<_PhonePage> {
  Filters filter = Filters.all;

  void _select(Filters f) => setState(() => filter = f);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TransactionsFilterTrigger(
              transactions: widget.txs,
              selected: filter,
              onChanged: _select,
            ),
          ),
          TransactionsSlimView(
            page: true,
            transactions: widget.txs,
            selectedFilter: filter,
            onFilterChanged: _select,
          ),
        ],
      ),
    );
  }
}

/// WCAG relative-luminance contrast ratio, via [Color.computeLuminance] - the
/// same helper `test/theme/theme_contrast_test.dart` uses, kept local because
/// that file is a test entry point rather than a library.
double _contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (la > lb ? la + 0.05 : lb + 0.05) / (la > lb ? lb + 0.05 : la + 0.05);
}
