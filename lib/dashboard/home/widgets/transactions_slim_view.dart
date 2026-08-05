// NOTE: `auto_size_text` is deliberately NOT imported here. The footer used to
// size itself with AutoSizeText over a `MediaQuery.textScalerOf(...).scale(...)`
// font size — a value derived continuously from ambient layout state, which is
// exactly the pattern commit 37639d5 traced to a permanent app freeze (a
// per-frame TextStyle thrashing skia's fixed-size ParagraphCache so layout never
// settled). Do not reintroduce it, and do not swap in a FittedBox either.
import 'package:flutter/material.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
import 'package:genius_wallet/components/cards/gw_section_title.dart';
import 'package:genius_wallet/components/effects/gw_hoverable.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/components/gw_control_track.dart';
// ponytail: imported for `DashboardScrollContainer` (the page's two cards),
// which closes an import cycle — dashboard_screen -> transactions_stream ->
// this file -> dashboard_screen. Dart permits cycles and there is no
// initialization hazard here: `DashboardScrollContainer` is a plain
// StatelessWidget with no top-level state, so nothing can be read before it is
// initialized. The real ceiling is a taste one — a widget file now imports a
// screen file. Upgrade path: move `DashboardScrollContainer` to
// `lib/components/cards/`; it already has five call sites in
// dashboard_screen.dart alone and is a surface primitive rather than a
// dashboard detail, so the move is a rename plus five imports. Taking the
// cycle now keeps this phase to zero new files.
import 'package:genius_wallet/dashboard/home/view/dashboard_screen.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_badge.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/utils/breakpoints.dart';

/// The ten filter identities.
///
/// Values are declared in the order the UI uses them: `all`, then the four
/// title-row chips, then the overflow types, then the two statuses.
///
/// The pre-12-04 enum was `{all, sent, received, escrow, mint}` while
/// `TransactionType` has SEVEN values — `swap`, `purchase` and `process` were
/// reachable by no filter at all, so a swap could only ever be found under
/// "All". Sketch 011 logged that as a coverage bug, not a styling preference;
/// `test/dashboard/transaction_filters_test.dart` is what keeps it closed.
///
/// [matches] is deliberately an exhaustive `switch` EXPRESSION: an eleventh
/// value cannot compile without a rule, which is the guard that was missing.
enum Filters {
  all('All', null),
  sent('Sent', TransactionBadgeKind.sent),
  received('Received', TransactionBadgeKind.received),
  mint('Mint', TransactionBadgeKind.mint),
  jobs('Computing', TransactionBadgeKind.job),
  escrow('Escrow', TransactionBadgeKind.escrow),
  swap('Swapped', TransactionBadgeKind.swap),
  purchase('Purchased', TransactionBadgeKind.purchase),
  pending('Pending', TransactionBadgeKind.pending),
  failed('Failed', TransactionBadgeKind.failed);

  const Filters(this.label, this.badgeKind);

  final String label;

  /// The badge identity this filter paints. Null only for [all] (which has no
  /// chip). Sharing 12-01's [badgeSpec] table is what makes a Sent chip and a
  /// Sent row badge the same mark — without it the bar stops reading as
  /// connected to the list below it.
  final TransactionBadgeKind? badgeKind;

  /// A transaction with no [TransactionType] is a plain transfer — the field
  /// is nullable in the model and older records predate it.
  static bool _isPlainTransfer(Transaction tx) =>
      tx.type == null || tx.type == TransactionType.transfer;

  bool matches(Transaction tx) => switch (this) {
    all => true,
    // Sent/Received are TRANSFER filters, not direction filters. Matching on
    // direction alone made every typed transaction leak into them: a purchase,
    // a swap, an escrow lock and a processing job all carry
    // `direction == sent`, so "Sent" listed 7 of the 11 fixtures instead of 3
    // and the categories stopped being categories. Every transaction now
    // belongs to exactly one type filter.
    sent =>
      _isPlainTransfer(tx) &&
          tx.transactionDirection == TransactionDirection.sent,
    received =>
      _isPlainTransfer(tx) &&
          tx.transactionDirection == TransactionDirection.received,
    mint => tx.type == TransactionType.mint,
    jobs => tx.type == TransactionType.process,
    // Escrow deliberately spans BOTH types; that must not regress.
    escrow => {
      TransactionType.escrow,
      TransactionType.escrowRelease,
    }.contains(tx.type),
    swap => tx.type == TransactionType.swap,
    purchase => tx.type == TransactionType.purchase,
    pending => tx.transactionStatus == TransactionStatus.pending,
    // `cancelled` folds into failed for the same reason `escrowRelease` folds
    // into escrow: someone hunting a transaction that did not go through does
    // not distinguish the two.
    failed => {
      TransactionStatus.failed,
      TransactionStatus.cancelled,
    }.contains(tx.transactionStatus),
  };

  /// The title row, in the locked order: Sent · Received · Mint · Jobs.
  static const List<Filters> primary = [sent, received, mint, jobs];

  /// Types behind the `⋯` trigger.
  static const List<Filters> overflowTypes = [escrow, swap, purchase];

  /// Statuses behind the `⋯` trigger, under their own header.
  static const List<Filters> overflowStatuses = [pending, failed];

  /// Whether [f] is only reachable through the overflow menu — the bar uses
  /// this to decide whether the `⋯` trigger takes the gradient.
  static bool isInOverflow(Filters f) =>
      overflowTypes.contains(f) || overflowStatuses.contains(f);
}

/// How many of [txs] each non-[Filters.all] filter matches.
///
/// Computed once per build and handed to the bar, rather than each menu item
/// running its own `where().length`.
Map<Filters, int> filterCounts(List<Transaction> txs) {
  return {
    for (final f in Filters.values)
      if (f != Filters.all) f: txs.where(f.matches).length,
  };
}

// ---------------------------------------------------------------------------
// Empty-state copy
// ---------------------------------------------------------------------------

/// The NEVER-TRANSACTED copy. Public constants rather than inline literals so
/// `transaction_filters_test.dart` can assert the filtered copy differs from
/// these by identity, not by a duplicated string that could drift.
const String emptyTransactionsTitle = 'No transactions yet';
const String emptyTransactionsMessage =
    'Your sends, receives and swaps will appear here.';

/// The FILTER-MATCHED-NOTHING title, e.g. `No swapped transactions`.
///
/// Naming the filter is the whole point: the shipped app printed
/// [emptyTransactionsTitle] for this case too, so a user who had simply picked
/// a filter with no hits was told their wallet was empty — which reads as a
/// broken load, not as a filter result.
String filteredEmptyTitle(Filters f) =>
    'No ${f.label.toLowerCase()} transactions';

/// The filter-matched-nothing message. Quotes how many transactions DO exist so
/// the state is self-evidently a filter result and not an empty wallet.
String filteredEmptyMessage(int total) =>
    'You have $total transaction${total == 1 ? '' : 's'}, '
    'but none match this filter.';

class TransactionsSlimView extends StatefulWidget {
  final List<Transaction> transactions;
  final bool? isShowOnlySGNUSTransactions;

  /// Selects the two-card PAGE layout (filter rail beside the list) over the
  /// dashboard PANEL (chips + `⋯` menu above the list).
  ///
  /// Defaults to false so both existing const call sites — `transactions_stream
  /// .dart:14` and `sgnus_transactions_screen.dart:48` — keep rendering exactly
  /// today's panel with no edit. The page presentation is opted into, never
  /// inherited.
  final bool page;

  const TransactionsSlimView({
    super.key,
    required this.transactions,
    this.isShowOnlySGNUSTransactions,
    this.page = false,
  });

  @override
  State<TransactionsSlimView> createState() => _TransactionsSlimViewState();
}

class _TransactionsSlimViewState extends State<TransactionsSlimView> {
  Filters selectedFilter = Filters.all;

  /// SGNUS scoping only, NO filter applied — the ONE list that both the menu
  /// counts and the filtered-empty "you have N" number read, so the two can
  /// never disagree about how much history exists (T-12-14). Counts computed
  /// over the already-filtered list would read 0 for every inactive filter.
  List<Transaction> get scopedTransactions =>
      (widget.isShowOnlySGNUSTransactions ?? false)
      ? widget.transactions.where((tx) => tx.isSGNUS ?? false).toList()
      : widget.transactions;

  /// The rail card's width. A FIXED literal, never a fraction of the incoming
  /// width — the freeze rule (37639d5) allows literals and bounded booleans and
  /// nothing else.
  ///
  /// The arithmetic it has to satisfy, MEASURED rather than derived on paper:
  /// [DashboardScrollContainer] is `GWDecorations.surface`, which carries a 1px
  /// hairline border (`genius_wallet_decorations.dart:97-101`) as well as its
  /// `space6` padding — so the content box is `220 - 2*1 - 2*12` = **194**, not
  /// 196. A row then spends `space6` each side (24), a 14px glyph and a
  /// `space4` gap (22), leaving **148px for the label plus the count**.
  ///
  /// ponytail: 148 is a fixed budget, so a long enough label beside a large
  /// enough count overflows rather than shrinking. Measured ceiling, in the
  /// widget-test fallback font (one em per character — the pessimistic case, at
  /// 13.25px/char): the widest labels, `Purchased` and `Computing`, draw
  /// **119.25px**, which leaves 28.75px — two digits, and a THREE-digit count
  /// overflows by exactly 11px. Real Inter is roughly half that advance, so on
  /// screen the ceiling is far higher; it has not been measured on a device and
  /// is not claimed here. Upgrade path if it is ever hit: widen this literal,
  /// which is the only value the rail's fit depends on. Do NOT reach for
  /// `FittedBox`/`AutoSizeText` — that is the 37639d5 pattern.
  static const double _railWidth = 220;

  /// The rail's natural CONTENT height, used as the list card's floor so the
  /// two cards end together when the list is short (sketch 023-V3).
  ///
  /// Arithmetic, not a guess — both cards sit in a `DashboardScrollContainer`
  /// with identical padding, so matching content heights matches card heights:
  ///   All summary  8 + 26 + 12            =  46
  ///   rule         8 +  1 +  8            =  17
  ///   'Type'       8 + 16 +  4            =  28
  ///   7 type rows  7 x 40                 = 280
  ///   rule                                =  17
  ///   'Status'                            =  28
  ///   2 status rows 2 x 40                =  80
  ///                                        ----
  ///                                         496
  ///
  /// A FLOOR, never a fixed height: a longer list grows past it, and the rail
  /// then simply ends higher, which is what a sidebar is allowed to do. What
  /// this prevents is the inverse — filtering down to one day leaving a 210px
  /// list stub beside a 500px rail, where the rail reads as the content and the
  /// list as a footnote.
  ///
  /// ponytail: a literal, so adding a tenth filter drifts it by one row height
  /// and the cards stop ending flush. The upgrade path is to measure the rail
  /// with a `GlobalKey` after layout — which costs a second frame and, worse,
  /// re-introduces a height derived from live layout, the exact shape 37639d5
  /// banned. The literal is the freeze-safe option and the drift is cosmetic.
  static const double _listCardFloor = 496;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final scoped = scopedTransactions;
    final txs = scoped.where(selectedFilter.matches).toList();

    return widget.page
        ? _page(context, gw, scoped, txs)
        : _panel(context, gw, scoped, txs);
  }

  /// The dashboard PANEL — the presentation that shipped. Chips and the `⋯`
  /// menu on the title row, list below, count in the footer.
  ///
  /// Also the narrow branch of [_page]: below 768 a page IS this panel, which
  /// is the correct answer rather than a compromise.
  Widget _panel(
    BuildContext context,
    GWColors gw,
    List<Transaction> scoped,
    List<Transaction> txs,
  ) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: GeniusBreakpoints.medium),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // `_panel` has two hosts with opposite height contracts. On the
          // DASHBOARD it sits in a fixed-height card, so it must fill that card
          // and scroll inside it. As the PAGE's narrow fallback it now sits in
          // the page's scroll view (sketch 023-V3), where height is unbounded —
          // and `Expanded` under an unbounded height is an assertion, not a
          // layout. One bool, read from the widget, not from constraints.
          final bool hug = widget.page;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: hug ? MainAxisSize.min : MainAxisSize.max,
            // GWSectionTitle owns its own space8 bottom gap, so the leading
            // title no longer needs the Column's 16px spacing above the list.
            children: [
              GWSectionTitle(
                title: 'Transactions',
                // Hidden ENTIRELY on an empty scope, not dimmed (sketch 021):
                // a control that filters an empty set is an offer the app
                // cannot honour, and it would sit directly above a block
                // explaining there is nothing here — two statements in one
                // panel contradicting each other. GWSectionTitle already
                // supports a null trailing (the title then left-aligns), so
                // this is the existing state, not a new one.
                //
                // The test is `scoped`, NOT `txs`, and that is the whole
                // decision. `txs.isEmpty` is the FILTERED-empty branch, whose
                // control must STAY: that wallet is not empty, and hiding the
                // bar there would strand the user on a filter with no route
                // back to All. Getting these two backwards is the defect this
                // comment exists to prevent — `transaction_filters_test.dart`
                // pins both directions.
                trailing: scoped.isEmpty
                    ? null
                    : _TransactionFilterBar(
                        selected: selectedFilter,
                        counts: filterCounts(scoped),
                        onChanged: (f) => setState(() => selectedFilter = f),
                      ),
              ),
              // NO header rule here, deliberately (sketch 019 variant B).
              // Every other dashboard panel goes straight from GWSectionTitle
              // to its list, letting the component's own space8 bottom gap do
              // the separating — Assets (coins_screen.dart) and Markets
              // (dashboard_markets.dart) both do exactly this. A rule on this
              // one panel was the only thing that differed dashboard-wide.
              // Row dividers stay: those are shared with Assets and Markets.
              if (hug)
                _body(context, gw, scoped, txs, scrollable: false)
              else
                Expanded(
                  child: _body(context, gw, scoped, txs, scrollable: true),
                ),
              // No footer count. It was removed on the walk: a running total
              // pinned to the bottom-right of the panel read as chrome nobody
              // needed, and it forced the panel to reserve space below the
              // list. The rail's own header carried the same number on the
              // page and that too was dropped, so neither presentation now
              // shows a total.
            ],
          );
        },
      ),
    );
  }

  /// The PAGE — two cards side by side: the filter rail, then the list.
  ///
  /// No [GWSectionTitle] and no footer here, both deliberately. The page title
  /// is `GWPageHeader`, supplied by the route (15-05); a panel header inside a
  /// page frame is defect #2 in the ROADMAP's diagnosis of this screen and
  /// re-adding it would reintroduce it. The footer count is gone because the
  /// All row absorbed it — two live totals on one screen is how they drift.
  Widget _page(
    BuildContext context,
    GWColors gw,
    List<Transaction> scoped,
    List<Transaction> txs,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The ONLY value the page derives from layout, and it is a BOOLEAN —
        // a bounded two-value set, exactly like the panel's `compact`. The
        // freeze rule (37639d5) forbids a dimension derived CONTINUOUSLY from
        // constraints, not a breakpoint: a bool cannot thrash the paragraph
        // cache because it cannot take a new value every frame.
        //
        // 768 (`GeniusBreakpoints.medium`) is the width below which a 220px
        // rail beside a transaction row stops being a page and starts being
        // two crushed columns.
        final bool wide = constraints.maxWidth >= GeniusBreakpoints.medium;

        // The narrow branch reuses the panel outright rather than duplicating
        // a third layout, so a phone-width /transactions route looks exactly
        // like the dashboard panel.
        if (!wide) {
          return _panel(context, gw, scoped, txs);
        }

        return Row(
          // start, NOT stretch. stretch forced both cards to the full window
          // height, so eleven rows of list sat in a 1400px card and the rail's
          // ~500px of content sat in another — two empty boxes that read worst
          // at fullscreen. Sketch 023-V3: each card ends where its content
          // ends, with a floor on the list so the pair stays visually paired.
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The rail disappears with the panel's chips on an empty scope —
            // 15-03's rule, applied to this presentation. A control that
            // filters an empty set is an offer the app cannot honour, and the
            // list card then takes the whole width.
            if (scoped.isNotEmpty) ...[
              SizedBox(
                width: _railWidth,
                child: DashboardScrollContainer(
                  child: _FilterRail(
                    selected: selectedFilter,
                    // `scoped`, NEVER `txs`: counts over the already-filtered
                    // list would read 0 for every inactive filter. Same list
                    // the panel reads at its own call site.
                    counts: filterCounts(scoped),
                    onChanged: (f) => setState(() => selectedFilter = f),
                  ),
                ),
              ),
              const SizedBox(width: GeniusWalletConsts.space6),
            ],
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: _listCardFloor),
                child: DashboardScrollContainer(
                  // NOT scrollable: the PAGE scrolls now
                  // (`transactions_screen.dart`), so the list lays itself out
                  // as a plain Column and the card is as tall as its rows.
                  child: _body(context, gw, scoped, txs, scrollable: false),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// The three body branches. Two of them are empty states, and they are
  /// deliberately NOT the same empty state (TX-11).
  Widget _body(
    BuildContext context,
    GWColors gw,
    List<Transaction> scoped,
    List<Transaction> txs, {

    /// True for the dashboard PANEL, whose card is a fixed height, so the list
    /// must scroll inside it. False for the PAGE, which scrolls as a whole
    /// (sketch 023-V3) — there the list is a plain Column and the card sizes
    /// to its rows.
    required bool scrollable,
  }) {
    // BRANCH 1 — this wallet has never transacted (within this scope). The one
    // branch allowed to be a dead end: there is nothing to show all of.
    if (scoped.isEmpty) {
      return const GWEmptyState(
        // Two horizontal opposed arrows (sketch 022) — literally the message
        // underneath. It is also the silhouette of the Swap tab's navbar mark
        // (`Icons.swap_horiz_outlined`,
        // `lib/components/overlay/responsive_overlay.dart:56`); the collision
        // was known and accepted when this was picked, so a walk should not
        // re-report it. If the meaning is ever wanted without the clash,
        // `Icons.swap_vert` is the one-word alternative.
        icon: Icons.sync_alt,
        title: emptyTransactionsTitle,
        message: emptyTransactionsMessage,
      );
    }

    // BRANCH 2 — history exists, this filter matched none of it. Different
    // icon, different title, different message, and a way out. Never "Buy
    // GNUS": this user's wallet is not empty.
    if (txs.isEmpty) {
      return GWEmptyState(
        icon: Icons.filter_alt_outlined,
        title: filteredEmptyTitle(selectedFilter),
        message: filteredEmptyMessage(scoped.length),
        actionLabel: 'Show all',
        onAction: () => setState(() => selectedFilter = Filters.all),
      );
    }

    // BRANCH 3 — the list. Flattened HERE, in build, not in itemBuilder: the
    // day/row/divider interleave is decided once per build instead of running
    // index arithmetic on every visible item every frame.
    final entries = <Widget>[];
    final days = groupTransactionsByDay(txs);
    for (var d = 0; d < days.length; d++) {
      final day = days[d];
      entries.add(
        Padding(
          padding: EdgeInsets.fromLTRB(
            GeniusWalletConsts.space6,
            // Measured against the other panels rather than picked by eye.
            //
            // FIRST header (space4): Assets and Markets put GWSectionTitle's
            // space8 bottom gap above a GWTokenRow that carries its own space4
            // vertical padding, so their title->first-content distance is 24.
            // A day label has no such padding of its own, so it pays the
            // space4 here to land on the same 24 and keep the three panels'
            // headers on one line.
            //
            // LATER headers (space12): the previous day's last row already
            // contributes space4 below it, so this yields 32 between one day's
            // last row and the next day's label — deliberately DOUBLE the 16
            // that separates two rows inside a day (space4 + space4). At the
            // old space8 a day boundary measured 24, identical to the
            // title->content gap, so day blocks did not read as separated.
            d == 0 ? GeniusWalletConsts.space4 : GeniusWalletConsts.space12,
            GeniusWalletConsts.space6,
            GeniusWalletConsts.space2,
          ),
          // 13px labelMd, not the sketch's 11px: genius_wallet_typography.dart
          // records the floor was deliberately raised from 12 to 13 because
          // 12px read too small on a touchscreen. Same deviation 12-03 took —
          // and it is exactly GWKicker's default step (sketch 065). Tracking
          // moved 0.7 -> 0.5 to join the one shared value.
          child: GWKicker(day.label),
        ),
      );
      for (var i = 0; i < day.items.length; i++) {
        final tx = day.items[i];
        entries.add(
          // One anatomy means one constructor: the four-branch switch on
          // tx.type is deleted, not moved.
          TransactionRow(
            tx: tx,
            onTap: () => showTransactionDetails(context, tx),
          ),
        );
        // No divider after a day's LAST row — the next day header is itself
        // the separator there, and a rule as well would double it.
        if (i != day.items.length - 1) {
          entries.add(Divider(height: 1, thickness: 1, color: gw.borderSubtle));
        }
      }
    }

    // A Column, not a shrink-wrapped ListView: `entries` is already fully
    // built above, so there is no laziness left to preserve and shrinkWrap
    // would only add a second layout pass over the same widgets.
    if (!scrollable) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: entries,
      );
    }

    return ListView.builder(
      // Zero, so the hairlines run full-bleed across the panel — the rows
      // carry their own space6/space4 padding.
      padding: EdgeInsets.zero,
      itemCount: entries.length,
      itemBuilder: (_, i) => entries[i],
    );
  }
}

/// The brand mark an ACTIVE filter label is painted with.
///
/// Dark keeps the real `brandCta` stops — as TEXT on the dark `surfaceMenu`
/// they measure 9.4:1 and 6.8:1. On the LIGHT menu surface (`#EFF2F6`) the
/// same two stops measure **1.65:1 and 2.28:1** — unreadable, and the same
/// class of defect UI-SPEC 3.1 still carries. Light therefore degrades the
/// shader to a flat light-safe brand blue (`brandPrimaryOnSurface`
/// `#0A6885`, 5.61:1). Collapsing a ShaderMask to a single repeated stop is
/// the pattern `gw_view_all_link.dart:67` already uses, so there is still
/// exactly one paint path — no branch in the widget tree.
///
/// Keyed off the surface actually being painted on rather than the global
/// appearance flag, so it cannot disagree with the [GWColors] in scope.
///
/// FILE-SCOPE, not a method, because it has a SECOND consumer: the page
/// filter rail's active-row underline (15-04, sketch 022 variant B2). That
/// mark is NON-TEXT, so it answers to WCAG 1.4.11's 3:1 rather than AA's
/// 4.5:1 — and `brandCta`'s blue stop `#0AAEE6` (the theme primitive layer's
/// gradientBlue) is **2.56:1** on white and fails even that, while the
/// degraded `#0A6885` is
/// 6.30:1 and passes. Routing the underline through here is what stops it
/// becoming a second, separately-drifting colour decision.
///
/// The luminance test reads `gw.surfaceMenu` as an APPEARANCE PROXY, not as
/// "the surface I am painting on" — the rail underline sits on the card, not
/// on the menu. That is deliberate: one token decides the branch for every
/// consumer, so the two marks cannot degrade at different thresholds. Do not
/// "fix" it into a per-surface argument.
/// Body moved to `GeniusWalletGradient.brandCtaText` on 2026-07-26, when the
/// navbar's Connect field became a third consumer (sketch 043 variant 4A).
/// The name and both call sites stay — the reasoning above is the shared
/// contract now, kept here because this file is where it was earned.
LinearGradient _activeLabelShader(GWColors gw) =>
    GeniusWalletGradient.brandCtaText(gw.surfaceMenu);

/// F1 two-tier filter control (sketch 014): four icon chips on the title row,
/// everything else behind a `⋯` menu with live counts.
///
/// Private to this file — it has exactly one call site, so it does not earn a
/// public component or a file of its own (the pattern `dashboard_screen.dart`
/// already uses for `_TimeframeSegment`).
///
/// Every dimension here is a fixed literal or a 4-pt token. No `FittedBox`, no
/// `AutoSizeText`: `BoxFit.scaleDown` derives a continuous scale from the
/// available space, which is the class of thing 37639d5 banned. The overflow
/// menu (`_overflowTrigger`) is what keeps the bar fitting instead.
class _TransactionFilterBar extends StatelessWidget {
  const _TransactionFilterBar({
    required this.selected,
    required this.counts,
    required this.onChanged,
  });

  final Filters selected;
  final Map<Filters, int> counts;
  final ValueChanged<Filters> onChanged;

  static const double _chipSize = 32;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    // Geometry is deliberately IDENTICAL to the chart's `_TimeframeSegment`
    // (dashboard_screen.dart): 3px track padding, hairline border, radiusPill,
    // 2px between chips. The two controls sit on the same dashboard and were
    // drifting apart — pill vs radiusMd, 3 vs 4 padding — which read as two
    // different design languages on one screen. Timeframe is the approved
    // shape (sketch 006/008), so the filter bar moves to it, not the reverse.
    //
    // The container itself now lives in `GWControlTrack`
    // (`lib/components/gw_control_track.dart`) — the same one
    // `_TimeframeSegment` and the Buy GNUS orders track build on, so this
    // track and the other two can no longer drift apart by editing one file.
    //
    // GWControlTrack inserts its 2px gap between EVERY top-level child it is
    // given. This bar's old geometry only ever had that gap between the
    // PRIMARY CHIPS — the divider supplies its own `space2` horizontal
    // padding on both sides (that IS its separation from its neighbours;
    // there was never a second, additional 2px gap on top of it) and the
    // overflow trigger sits flush against the divider's padding too. Passing
    // chips/divider/trigger as three separate top-level children to
    // GWControlTrack would add two 2px gaps that never existed before,
    // widening this bar by 4px (proven by `transaction_filters_test.dart`'s
    // pixel-pinned `expect(bar.width, 183)`, which is the authority here).
    // So the pre-existing inner `Row` — chips with their own gaps, then the
    // divider, then the trigger — is passed to `GWControlTrack` as a SINGLE
    // child, keeping its rendered geometry byte-for-byte unchanged while
    // still routing the outer fill/border/radius/track-padding through the
    // shared container.
    return GWControlTrack(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < Filters.primary.length; i++) ...[
              if (i > 0) const SizedBox(width: 2),
              _chip(gw, Filters.primary[i]),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GeniusWalletConsts.space2,
              ),
              child: SizedBox(
                width: 1,
                height: 20,
                child: ColoredBox(color: gw.borderSubtle),
              ),
            ),
            _overflowTrigger(context, gw),
          ],
        ),
      ],
    );
  }

  Widget _chip(GWColors gw, Filters f) => _FilterChip(
    filter: f,
    active: f == selected,
    size: _chipSize,
    // Tapping the active chip clears back to All — the
    // `emptySelectionAllowed` behaviour the segmented button had.
    onTap: () => onChanged(f == selected ? Filters.all : f),
  );

  Widget _overflowTrigger(BuildContext context, GWColors gw) {
    // A filter chosen from the menu leaves no mark on the title row, so
    // without this the list reads as unfiltered while showing a partial list.
    final bool filtered = Filters.isInOverflow(selected);

    return PopupMenuButton<Filters>(
      padding: EdgeInsets.zero,
      tooltip: filtered ? 'Filtered: ${selected.label}' : 'More filters',
      color: gw.surfaceMenu,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
        side: BorderSide(color: gw.borderSubtle),
      ),
      position: PopupMenuPosition.under,
      onSelected: (f) => onChanged(f == selected ? Filters.all : f),
      itemBuilder: (context) => [
        _header(gw, 'More types'),
        for (final f in Filters.overflowTypes) _menuItem(gw, f),
        // Colour pinned, not inherited: the app-wide `dividerTheme` is
        // `colorScheme.surfaceContainerHighest`, so a bare PopupMenuDivider
        // would be the one hairline in this control not drawn in
        // `gw.borderSubtle` — same 1px rule as the list separators below.
        PopupMenuDivider(thickness: 1, color: gw.borderSubtle),
        _header(gw, 'Status'),
        for (final f in Filters.overflowStatuses) _menuItem(gw, f),
      ],
      child: Container(
        width: _chipSize,
        height: _chipSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: filtered ? GeniusWalletGradient.brandCta : null,
          borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusSm),
        ),
        child: Icon(
          Icons.more_horiz,
          size: 15,
          color: filtered ? context.gw.textOnBrand : gw.textSecondary,
        ),
      ),
    );
  }

  PopupMenuItem<Filters> _header(GWColors gw, String text) {
    return PopupMenuItem<Filters>(
      enabled: false,
      // Non-interactive label — no 40px touch target to honour, so it takes
      // the tighter step and lets the groups read as headers, not entries.
      height: GeniusWalletConsts.space16,
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space6,
      ),
      child: Text(
        text,
        style: GeniusWalletTypography.labelMd.copyWith(color: gw.textSecondary),
      ),
    );
  }

  PopupMenuItem<Filters> _menuItem(GWColors gw, Filters f) {
    final bool active = f == selected;
    final label = Text(
      f.label,
      style: GeniusWalletTypography.labelMd.copyWith(
        // Opaque white when active because `srcIn` recolours what it is
        // given — a themed colour would come out muddied by the gradient.
        color: active ? Colors.white : gw.textPrimary,
        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
      ),
    );

    return PopupMenuItem<Filters>(
      value: f,
      // 40px is the height the navbar normalizes every interactive control to
      // (Buy GNUS and the whole right cluster), so the menu matches the app's
      // one control rhythm. Material's own default is 48 plus padding, which
      // is what made these rows read as oversized.
      height: GeniusWalletConsts.space20,
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space6,
      ),
      child: Row(
        children: [
          // The glyph NEVER changes with selection: same icon, same colour,
          // active or not. Locked decision — do not tint it, do not gradient
          // it. Only the label carries the selected state.
          badgeGlyph(
            badgeSpec(f.badgeKind!, gw),
            color: gw.textSecondary,
            size: 14,
          ),
          const SizedBox(width: GeniusWalletConsts.space4),
          Expanded(
            child: active
                ? ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: _activeLabelShader(gw).createShader,
                    child: label,
                  )
                : label,
          ),
          Text(
            '${counts[f] ?? 0}',
            // Tabular figures so the count column does not jitter.
            style: GeniusWalletTypography.numericBody.copyWith(
              fontSize: 13,
              color: gw.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// One filter chip. Icon-only in every state at every width — the active one
/// is marked by its gradient fill alone, never by revealing a label, because a
/// chip that grows on tap shoves its neighbours sideways under the cursor. The
/// tooltip carries the name.
///
/// Hover plumbing moved into `GWHoverable` (23-05); this widget held no other
/// state, so it is a `StatelessWidget` now. The design-system hover is still
/// the "lift chip" (sketch 008 variant D), the standard for ALL interactive
/// chrome — so an unselected chip lifts onto `surfaceElevated` exactly the way
/// `_TimeframeTab` does on the chart, and the two controls keep behaving
/// identically under the same cursor.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.filter,
    required this.active,
    required this.size,
    required this.onTap,
  });

  final Filters filter;
  final bool active;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    return Semantics(
      label: filter.label,
      button: true,
      selected: active,
      child: Tooltip(
        message: filter.label,
        child: GWHoverable(
          builder: (hovered) {
            final bool lifted = hovered && !active;

            final Color fg = active
                ? context
                      .gw
                      .textOnBrand // 10.6:1 / 7.7:1 on the two stops
                : (lifted ? gw.textPrimary : gw.textMutedOnSunken);

            // InkWell for focus + Enter/Space (WCAG 2.1.1 Level A). The chip
            // draws only a glyph, so `label` + excludeSemantics is what gives
            // a screen reader the filter's name instead of nothing.
            return Semantics(
              button: true,
              selected: active,
              label: filter.label,
              excludeSemantics: true,
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: onTap,
                  hoverColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    GeniusWalletConsts.radiusPill,
                  ),
                  child: AnimatedContainer(
                    // 120ms matches _TimeframeTab; the two controls must settle
                    // at the same speed or the dashboard feels assembled from
                    // parts.
                    duration: const Duration(milliseconds: 120),
                    height: size,
                    width: size,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      // Active is the brandCta GRADIENT, never a flat blue —
                      // the app-wide rule the 260721-0ze brand sweep set.
                      gradient: active ? GeniusWalletGradient.brandCta : null,
                      color: active
                          ? null
                          : (lifted ? gw.surfaceElevated : Colors.transparent),
                      borderRadius: BorderRadius.circular(
                        GeniusWalletConsts.radiusPill,
                      ),
                    ),
                    child: badgeGlyph(
                      badgeSpec(filter.badgeKind!, gw),
                      color: fg,
                      size: 15,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The PAGE filter control: the `⋯` menu unrolled into a permanent rail
/// (sketch 020 variant B, active mark locked by sketch 022 variant B2).
///
/// The overflow menu exists ONLY because a 376px dashboard panel cannot show
/// nine filters. A 1280px page can, so on the page the same rows live in a
/// `Column` instead of a popup — this is not a new control, it is [_menuItem]
/// with the popup taken off.
///
/// Private to this file with one call site, same as [_TransactionFilterBar].
/// Deliberately NOT factored into a shared "chip or row" abstraction with
/// [_FilterChip]: the two disagree on geometry (32px square vs 40px row), on
/// tap semantics (the chip toggles back to All, the rail does not) and on the
/// active mark (gradient fill vs w700 + underline). An abstraction over three
/// disagreements is the abstraction `./CLAUDE.md` says not to write.
class _FilterRail extends StatelessWidget {
  const _FilterRail({
    required this.selected,
    required this.counts,
    required this.onChanged,
  });

  final Filters selected;
  final Map<Filters, int> counts;
  final ValueChanged<Filters> onChanged;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    Widget row(Filters f, int count) => _RailRow(
      filter: f,
      count: count,
      active: f == selected,
      // Tap the active row to clear back to All — the same toggle the panel's
      // chips use (`_TransactionFilterBar._chip`). With no All element in the
      // rail, this IS the way back to unfiltered, so it is a feature, not the
      // misfire it would be if an explicit All also existed.
      onTap: () => onChanged(f == selected ? Filters.all : f),
    );

    return SingleChildScrollView(
      // Not decoration. All + a header + seven type rows + a divider + a
      // header + two status rows is ~480px, which does not fit a short laptop
      // window under the page header. A scroll view is also the freeze-safe
      // way to handle it (37639d5): it clips, it does not derive a shrink
      // factor from the available height.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // No All element at all (sketch 023, walk 2). It was tried as a row,
          // then as a summary; both read as clutter above the first real group.
          // The way back to unfiltered is the tap-the-active-row-to-clear
          // toggle in [row] below — the same affordance the panel's chips use.
          // The rail therefore opens straight on the first group header, and
          // there is no leading rule to be asymmetric with.
          _groupHeader(gw, 'Type'),
          for (final f in Filters.primary) row(f, counts[f] ?? 0),
          for (final f in Filters.overflowTypes) row(f, counts[f] ?? 0),
          _rule(gw),
          _groupHeader(gw, 'Status'),
          for (final f in Filters.overflowStatuses) row(f, counts[f] ?? 0),
        ],
      ),
    );
  }

  /// The rail's group separator. Colour PINNED, not inherited — same reason the
  /// menu's `PopupMenuDivider` pins it: the app-wide `dividerTheme` is a
  /// different colour, and this hairline must match the list separators and the
  /// menu's.
  ///
  /// Shared by BOTH boundaries. Before sketch 023 the Status boundary had one
  /// and the All boundary did not, which is the asymmetry that made `All 11`
  /// look wrong — one helper makes that impossible to reintroduce by omission.
  Widget _rule(GWColors gw) => Padding(
    padding: const EdgeInsets.symmetric(vertical: GeniusWalletConsts.space4),
    child: Divider(height: 1, thickness: 1, color: gw.borderSubtle),
  );

  /// The same type treatment `_TransactionFilterBar._header` gives the menu's
  /// group labels. The WORDING differs from the menu's "More types" on
  /// purpose: unrolled, nothing is "more".
  Widget _groupHeader(GWColors gw, String text) => Padding(
    padding: const EdgeInsets.fromLTRB(
      GeniusWalletConsts.space6,
      GeniusWalletConsts.space4,
      GeniusWalletConsts.space6,
      GeniusWalletConsts.space2,
    ),
    child: Text(
      text,
      style: GeniusWalletTypography.labelMd.copyWith(color: gw.textSecondary),
    ),
  );
}

/// One rail row: `_menuItem`'s geometry byte for byte, plus the navbar's
/// active-tab mark.
///
/// Hover plumbing moved into `GWHoverable` (23-05); this widget held no other
/// state, so it is a `StatelessWidget` now, exactly like [_FilterChip] — the
/// sketch-008 "lift chip" at 120ms, which is the standard for ALL interactive
/// chrome in this app and is matched to `_TimeframeTab` so the controls settle
/// at one speed.
class _RailRow extends StatelessWidget {
  const _RailRow({
    required this.filter,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final Filters filter;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    // The glyph NEVER changes with selection: same mark, same
    // `textSecondary`, active or not. That is the rule locked at `_menuItem`
    // and restated by all five variants in sketch 022 — do not tint it, do not
    // swap it, do not gradient it. Only the label carries the selected state.
    //
    // `Filters.all` is the one value with no `badgeKind`, so it needs its own
    // glyph. A neutral ledger mark meaning "everything", listed by sketch 021
    // §4 as an unpicked empty-state candidate and used nowhere else in the app,
    // so it collides with no existing meaning. The alternative was a blank
    // glyph slot, which reads as a missing icon rather than as a deliberate
    // absence.
    final Widget glyph = filter.badgeKind == null
        ? Icon(Icons.list_alt_outlined, size: 14, color: gw.textSecondary)
        : badgeGlyph(
            badgeSpec(filter.badgeKind!, gw),
            color: gw.textSecondary,
            size: 14,
          );

    return Semantics(
      label: filter.label,
      button: true,
      selected: active,
      // No Tooltip, unlike `_FilterChip`: the rail SHOWS its labels, which is
      // the entire reason it exists.
      child: GWHoverable(
        builder: (hovered) {
          final bool lifted = hovered && !active;

          return GestureDetector(
            // No `behavior: HitTestBehavior.opaque` — measured as redundant, not
            // forgotten. The default `deferToChild` already covers the whole 40px
            // row, because `RenderDecoratedBox.hitTestSelf` delegates to the
            // decoration's SHAPE and ignores its colour, so the AnimatedContainer
            // hit-tests across its full area even while its fill is transparent.
            // A tap in the dead zone between the label and the count selects the
            // row either way. `_FilterChip` relies on the same thing.
            onTap: onTap,
            child: AnimatedContainer(
              // 120ms, matched to `_FilterChip` and `_TimeframeTab`.
              duration: const Duration(milliseconds: 120),
              height: GeniusWalletConsts.space20,
              decoration: BoxDecoration(
                // The fill spans the row's full width so the lift reads as a
                // chip, not as a text highlight. `lifted` excludes the active
                // row: hover and active must not collapse into one fill, which
                // is the collision that killed sketch 022's variant E.
                color: lifted ? gw.surfaceElevated : Colors.transparent,
                borderRadius: BorderRadius.circular(
                  GeniusWalletConsts.radiusSm,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: GeniusWalletConsts.space6,
                ),
                child: Row(
                  children: [
                    glyph,
                    const SizedBox(width: GeniusWalletConsts.space4),
                    // B2, the navbar's active-tab mark copied outright
                    // (`responsive_overlay.dart:301-368`): a bold white label
                    // with a gradient rule under it, and the rule is the width of
                    // the WORD. Same IntrinsicWidth + stretch content-tracking
                    // the navbar uses.
                    //
                    // IntrinsicWidth is NOT the 37639d5 pattern: it is a
                    // layout-only intrinsic pass over a two-child subtree, and it
                    // derives no font size, scale or dimension from the incoming
                    // constraints. The `Spacer()` after it is what keeps the
                    // count right-aligned once the label stops filling the row.
                    IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            filter.label,
                            style: GeniusWalletTypography.labelMd.copyWith(
                              // `textPrimary` in BOTH states — the label is NEVER
                              // recoloured, and no ShaderMask. That is the whole
                              // difference between B2 and the rejected B, and it
                              // is why the rail carries no text degradation that
                              // has to stay in sync with the underline's.
                              color: gw.textPrimary,
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            height: 2,
                            decoration: BoxDecoration(
                              // ALWAYS rendered, transparent when inactive, so
                              // every row is the same height and the rail does
                              // not twitch when selection moves — a layout jump
                              // under the cursor is exactly what the 120ms hover
                              // exists to avoid.
                              //
                              // Painted through `_activeLabelShader`, NOT through
                              // `brandCta` directly. This rule is a NON-TEXT mark
                              // and answers to WCAG 1.4.11's 3:1; the raw blue
                              // stop fails that on white while the function's
                              // light degradation passes. See its doc comment for
                              // the measured ratios.
                              gradient: active ? _activeLabelShader(gw) : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$count',
                      // Tabular figures so the count column does not jitter.
                      // Never gradient, never bold, never changed by selection:
                      // `filterCounts()` runs over the UNFILTERED list on
                      // purpose, so these numbers do not move when you filter and
                      // marking state on one would promise a motion that never
                      // comes (sketch 022 rejected variant C for exactly this).
                      style: GeniusWalletTypography.numericBody.copyWith(
                        fontSize: 13,
                        color: gw.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
