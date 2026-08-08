import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_detail_grid.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
import 'package:genius_wallet/components/effects/gw_hover_row.dart';
import 'package:genius_wallet/components/effects/gw_hoverable.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_badge.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/web/web_utils.dart';
import 'package:intl/intl.dart';

final _dateFormat = DateFormat("MMMM d, y 'at' h:mm a");

String _capitalizeStatus(TransactionStatus status) =>
    status.name[0].toUpperCase() + status.name.substring(1);

/// Above this row width, the row is the WIDE transactions page: it gains the
/// Status pill + a fixed-width amount column (sketch 030-A2). Below it — the
/// dashboard panel — the row stays the compact two-part item and the status
/// remains folded into the subtitle. A row-local width is the right signal:
/// the page list card is ~760px+, the dashboard panel column stays well under
/// this, so the two presentations separate cleanly without threading a flag
/// through every call site.
const double _wideRowThreshold = 720;

/// The amount column's reserved width on the wide page. Fixed — NOT the widest
/// amount re-measured every frame (that scan is the class of thing that froze
/// the app, 37639d5) — so every amount's left edge, and therefore the Status
/// pill's right edge one `space6` to its left, lands on a single vertical line
/// (Jakub's "all statuses respect one place"). Sized for the largest realistic
/// amount; a rare bigger one ellipsizes and keeps its `exactAmount` tooltip.
const double _wideAmountWidth = 184;

/// Narrow row: the name+tag block takes this many parts against the amount's
/// 1. Was 1:1, which gave the amount half the row for a string needing far
/// less. A flex ratio, not a measured width - measuring per layout is what the
/// freeze rule bans (37639d5).
///
/// Cost: long amounts truncate sooner; they keep their `exactAmount`
/// tooltip. Upgrade path: 3:2 if balances read short.
const int _narrowNameFlex = 2;

/// The narrow row's status tail cap, and the row's ONLY non-flex subtitle child.
///
/// Why a cap at all: everything else on the subtitle line is inside an
/// `Expanded`, so the tail is the single element that could push the `Row` past
/// its line and raise a `RenderFlex` overflow. `statusLabel` is caller-supplied
/// (the Buy GNUS orders rail sets `Expired`), so its length is not this file's
/// to assume - the `ConstrainedBox` is what bounds it (T-txr-01).
///
/// Why 76: `Cancelled` is the widest word the status can print and measures
/// 66.0px in the shipped Inter at `bodySm`, so 76 clears it by 10 and the cap
/// never bites in practice. It must also stay inside the NARROWEST middle column
/// the suite pumps - 90px at the 320px stress case - less the `space2` gutter,
/// which leaves 10px of slack there too. 76 is on the 4-pt grid.
///
/// `transaction_row_subtitle_test.dart` asserts every status word stays under
/// this, so a longer one reddens rather than silently ellipsising.
const double _narrowStatusMaxWidth = 76;

/// THE colour of a status - foreground and its wash - for every consumer.
///
/// This used to be a `switch` inside `_statusPill` and, twenty lines away, a
/// `isDead ? gw.statusError : null` on the receipt's Status row. Two rules for
/// one fact, and they disagreed exactly as you would expect: the pill coloured
/// all four states while the row coloured only `failed` and `cancelled`, so a
/// Completed receipt showed a green pill above a plain white "Completed" and a
/// Pending one showed an amber pill above a white "Pending".
///
/// Jakub, 2026-07-28: the completed status is missing its colours, and the two
/// places that print it should be connected through one component. Connected
/// here: one function, and neither consumer can drift from the other again.
({Color fg, Color wash}) txStatusColors(
  TransactionStatus status,
  GWColors gw,
) => switch (status) {
  TransactionStatus.completed => (
    fg: gw.statusSuccess,
    wash: gw.statusSuccess.withValues(alpha: 0.14),
  ),
  // Foreground is statusWarningText, NOT statusWarning: the latter is
  // fill-tuned (~1.6:1 on a light canvas) and was invisible as pill text in
  // light mode -- the exact consumer gw_warning_note.dart's note said was
  // "waiting for" this token. The wash stays statusWarning: it IS a fill.
  TransactionStatus.pending => (
    fg: gw.statusWarningText,
    wash: gw.statusWarning.withValues(alpha: 0.16),
  ),
  TransactionStatus.failed => (
    fg: gw.statusError,
    wash: gw.statusError.withValues(alpha: 0.14),
  ),
  // Slate, not red: a cancelled transaction is not a failure, and
  // `surfaceMenu` is a real step up from the 156-A panel behind it.
  TransactionStatus.cancelled => (fg: gw.textSecondary, wash: gw.surfaceMenu),
};

/// The Status pill: label + dot in the status colour on a low-alpha wash of it,
/// reusing the badge palette so pill and badge never disagree on what "failed"
/// looks like. Used by the wide transactions row AND by the receipt hero.
///
/// All four tones come from [txStatusColors]: completed/failed use the
/// appearance-aware `gw.*` colours, cancelled uses `textSecondary`, and
/// pending uses `statusWarningText`.
///
/// The pending case USED to read the mode-invariant `statusWarning` fill and
/// measured 1.59:1 as a label on the light wash — this comment previously
/// deferred that "to the light pass". It was fixed on 2026-07-29 instead: the
/// upgrade path it predicted (a darker light-mode amber behind its own token)
/// is exactly what `statusWarningText` is — #92400E, landing at 6.56 / 5.93 /
/// 5.15 on surfaceElevated / surfaceMenu / surfaceBase.
///
/// ponytail: completed and failed still do NOT clear AA as labels in light
/// mode — measured 3.77 / 3.39 / 2.91 and 3.89 / 3.49 / 2.99 against a 4.5:1
/// floor (13px w600 is below WCAG's 18.66px large-text threshold). Their
/// light values are already AA-divergent and still miss, because the wash is a
/// translucent tint of the same hue. Ceiling: only the pending tone is proven
/// in light mode. Upgrade path: `statusSuccessText`/`statusErrorText`
/// mirroring `statusWarningText`, then extend Part 8 of
/// `test/theme/theme_contrast_test.dart` to all three tones in both modes. See
/// `.planning/todos/pending/2026-07-29-status-pill-success-error-fail-aa-in-light-mode.md`.
///
/// [label] overrides the text only - never the paint, which stays the four-tone
/// ladder above. Null keeps today's behaviour (the enum's own name); a caller
/// supplies it when the enum name is not the truthful word for the state, e.g.
/// a Banxa `Expired` order folded onto [TransactionStatus.failed].
Widget _statusPill(TransactionStatus status, GWColors gw, {String? label}) {
  final (:fg, :wash) = txStatusColors(status, gw);
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: GeniusWalletConsts.space4,
      vertical: 3,
    ),
    decoration: BoxDecoration(
      color: wash,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label ?? _capitalizeStatus(status),
          maxLines: 1,
          softWrap: false,
          style: GeniusWalletTypography.labelMd.copyWith(
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ],
    ),
  );
}

/// The amount's colour, from 12-02's tone — never from a re-inspection of
/// `tx.type`. `none` (a dash: failed, cancelled, a processing job) takes
/// `textSecondary` and NOT the sketch's `--text-primary-38`, which measures
/// ~3.0:1 on the dark panel and fails AA for what is meaningful text.
Color _toneColor(TxAmountTone tone, GWColors gw) => switch (tone) {
  TxAmountTone.incoming => gw.statusSuccess,
  TxAmountTone.outgoing => gw.textPrimary,
  TxAmountTone.none => gw.textSecondary,
};

/// Copy of `_FallbackDot` in `gw_token_row.dart` (private there) so the Assets
/// panel and the Transactions panel degrade identically on a missing coin art.
Widget _fallbackDot(GWColors gw) => CircleAvatar(
  radius: 20,
  backgroundColor: gw.surfaceMenu,
  child: Icon(Icons.token, size: 18, color: gw.textSecondary),
);

Widget _coinImage(String symbol, GWColors gw, {BoxFit fit = BoxFit.contain}) {
  // `symbol` arrives ALREADY sanitised by 12-02's `sanitizeCoinAsset` (a-z0-9,
  // max 12). Never re-derive this path from `tx.coinSymbol` — that raw value is
  // attacker-influenced and this is a filesystem path (T-12-01).
  if (symbol.isEmpty) {
    return _fallbackDot(gw);
  }
  return Image.asset(
    'assets/images/crypto/$symbol.png',
    fit: fit,
    errorBuilder: (_, _, _) => _fallbackDot(gw),
  );
}

/// The identity slot: one coin, or two overlapped for a swap, with the badge
/// on top. [size] is always a literal (40 in the row, 60 in the drawer) — no
/// dimension here is derived from constraints, per the 37639d5 freeze rule.
Widget _identity(TxRowContent content, GWColors gw, {required double size}) {
  final isPair = content.iconSymbols.length > 1;
  // 0.6 of a literal size, so the whole set is {24, 36} — still a bounded set.
  final sub = size * 0.6;

  return SizedBox(
    width: size,
    height: size,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        if (!isPair)
          Positioned.fill(child: _coinImage(content.iconSymbols.first, gw))
        else ...[
          Positioned(
            left: 0,
            top: 0,
            child: SizedBox(
              width: sub,
              height: sub,
              child: _coinImage(content.iconSymbols.first, gw),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: sub,
              height: sub,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: gw.surfaceElevated, width: 2),
              ),
              // Asset art only. The old `_buildOverlappedIcons` used
              // NetworkImage(fromIconUrl), which fires one network fetch per
              // VISIBLE ROW inside a scrolling list (T-12-02).
              child: ClipOval(
                child: _coinImage(
                  content.iconSymbols[1],
                  gw,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
        // Last in the stack so it paints on top of the coin art.
        Positioned(
          right: -2,
          // Swap-only, deliberate: the bottom-right corner is occupied by the
          // to-token, so the badge moves to the top-right there. Flagged for
          // 12-06's walk.
          bottom: isPair ? null : -2,
          top: isPair ? -2 : null,
          child: TransactionBadge(kind: content.badge),
        ),
      ],
    ),
  );
}

/// ONE row for all seven `TransactionType` values.
///
/// Pure presentation: it renders [txRowContent]'s record and decides nothing.
/// There is deliberately no `switch (tx.type)` and no status branching in here
/// — a missing case belongs in 12-02's derivation, not in this widget. That
/// single rule is what makes "one anatomy" true rather than aspirational.
///
/// Geometry matches `GWTokenRow` (40px icon slot, space6/space4 padding,
/// radiusMd InkWell) so Assets and Transactions read as one system.
class TransactionRow extends StatelessWidget {
  const TransactionRow({
    super.key,
    required this.tx,
    this.onTap,
    this.contentOverride,
  });

  final Transaction tx;
  final VoidCallback? onTap;

  /// A record built by the CALLER, used verbatim in place of [txRowContent]'s
  /// derivation. Supplying it means the caller owns the whole record - the row
  /// still decides nothing, which is the property that keeps this file free of
  /// per-source branches.
  ///
  /// The one caller today is the Buy GNUS orders rail: a Banxa order's value
  /// line is the fiat actually PAID, which is a different FACT from the price
  /// map's estimate rather than an override of it (D-03). `??` short-circuits,
  /// so a row with an override never calls `livePricesBySymbol()` and never
  /// touches Hive.
  final TxRowContent? contentOverride;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that re-skins
    // this row on a live appearance toggle.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final content =
        contentOverride ?? txRowContent(tx, prices: livePricesBySymbol());

    // Phone-only density. Read from the WINDOW, not this row's constraints
    // like `wide` below: the dashboard panel is ~376px wide but sits on a
    // desktop, so row width would have re-styled desktop too.
    final bool compact = !GeniusBreakpoints.useDesktopLayout(context);

    // `titleText` and `actionChip` locals lived here until the 2026-08-07
    // merge. Scheme C inlined the title into the Column below and DELETED the
    // action chip outright: its `surfaceMenu` box measured 1.13:1 against the
    // row canvas and was 44.5px on a phone, too narrow for 6 of the 8 strings
    // `_actionFor` can return, so it clipped the word it existed to show. The
    // action now leads the subtitle as `content.subtitleLead`. Their `compact`
    // font sizes were carried to their replacements rather than lost.

    final Widget amountText = Text(
      content.amount,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.right,
      style: GeniusWalletTypography.numericBody.copyWith(
        // Still the largest thing in the row, and still w600.
        fontSize: compact ? 13 : 16,
        fontWeight: FontWeight.w600,
        color: _toneColor(content.tone, gw),
      ),
    );

    // Shared by both presentations: right-aligned amount over its value line.
    // On the narrow panel it sits in an Expanded (shrinks/ellipsises); on the
    // wide page it sits in a fixed-width SizedBox so every amount aligns.
    final Widget amountColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tooltip ONLY when the clamp actually lost something — wrapping
        // unconditionally attaches an empty tooltip to every row.
        if (content.exactAmount != null)
          Tooltip(message: content.exactAmount!, child: amountText)
        else
          amountText,
        if (content.valueLine != null) ...[
          SizedBox(height: compact ? 1 : GeniusWalletConsts.space2),
          Text(
            content.valueLine!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: GeniusWalletTypography.bodySm.copyWith(
              // Matches the subtitle across the row.
              fontSize: compact ? 11 : null,
              color: gw.textSecondary,
            ),
          ),
        ],
      ],
    );

    // The hover treatment moved into `GWHoverRow` on 2026-07-30 and this row is
    // where it came from: of the app's three tappable lists, this was the only
    // one that carried its own transparent `Material` and passed a `radiusMd`,
    // which is why it was the only one whose highlight was both visible and
    // rounded. Nothing here changes shape - the component states the hover
    // colour explicitly instead of inheriting `ThemeData`'s 4% default, so the
    // highlight is one step stronger and identical across all three lists.
    return GWHoverRow(
      onTap: onTap,
      child: Padding(
        // Halved on phone so more history fits on screen.
        padding: EdgeInsets.symmetric(
          horizontal: compact
              ? GeniusWalletConsts.space3
              : GeniusWalletConsts.space6,
          vertical: compact
              ? GeniusWalletConsts.space2
              : GeniusWalletConsts.space4,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // BOOLEAN from constraints, never a per-frame dimension — the
            // freeze rule (37639d5) bans continuous sizes, not breakpoints.
            final bool wide = constraints.maxWidth >= _wideRowThreshold;
            return Row(
              children: [
                // DESKTOP: time leads the row — fixed-width and tabular, so the
                // token icons line up in a straight column behind it and the
                // eye can scan either "when" or "what" down a single edge.
                //
                // PHONE: time is dropped and the icon leads, reclaiming 44px +
                // its gap for the title and amount. The day header still names
                // the day and the receipt drawer keeps the full timestamp, so
                // only the minute is lost.
                if (!compact) ...[
                  SizedBox(
                    width: 44,
                    child: Text(
                      content.time,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      style: GeniusWalletTypography.numericBody.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        // Not the sketch's --text-primary-38 (~3.0:1): the
                        // timestamp is meaningful text and must clear AA.
                        color: gw.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: GeniusWalletConsts.space6),
                ],
                // 40 -> 28 on a phone (30% smaller).
                _identity(content, gw, size: compact ? 28 : 40),
                SizedBox(
                  width: compact
                      ? GeniusWalletConsts.space3
                      : GeniusWalletConsts.space6,
                ),
                Expanded(
                  flex: compact ? _narrowNameFlex : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Token-first (010-A), and since 179-C the token is ALONE
                      // here: the action word moved down to lead the subtitle.
                      // The chip it used to sit in was a `surfaceMenu` container
                      // measuring 1.13:1 against the row canvas, and its box was
                      // 44.5px on a phone - too narrow for 6 of the 8 strings
                      // `_actionFor` can return, so it clipped the word it
                      // existed to show. 010-A's decision is unchanged and this
                      // strengthens it: the asset now has the whole line.
                      //
                      // A bare `Text` in the `Column`, not a `Row`: it takes
                      // loose constraints here and ellipsises on its own, so
                      // nothing on this line can overflow.
                      Text(
                        content.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GeniusWalletTypography.titleMd.copyWith(
                          // From develop's `titleText` local (260806-hfe),
                          // which scheme C inlined here. Carried across the
                          // merge rather than dropped with the widget that
                          // used to hold it.
                          fontSize: compact ? 14 : null,
                          fontWeight: FontWeight.w600,
                          color: gw.textPrimary,
                        ),
                      ),
                      // `compact ? 1` comes from develop's phone-width work
                      // (260806-hfe) and is kept through this merge: scheme C
                      // rebuilt the subtitle around it, not instead of it.
                      SizedBox(height: compact ? 1 : GeniusWalletConsts.space2),
                      // THE SUBTITLE, in three pieces and TWO children.
                      //
                      // The lead is protected by being FIRST IN THE PARAGRAPH,
                      // not by a flex fit, and that distinction is the whole
                      // design. Flutter's `Row` hands a loose flex child only its
                      // own share of the free space and never passes back a
                      // narrower sibling's remainder - that is the precise
                      // mechanism that capped the deleted chip at 44.5px. Two
                      // NON-flex children would instead raise a `RenderFlex`
                      // overflow at the 320px case the suite pumps. An end
                      // ellipsis over one paragraph gives the qualifier-first
                      // degradation order for free and cannot overflow at all.
                      Row(
                        children: [
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  if (content.subtitleLead != null)
                                    TextSpan(
                                      text: content.subtitleLead,
                                      // Jakub, 2026-08-07 on device: at w500
                                      // against the base's w400, in the SAME
                                      // colour and joined by a plain space, the
                                      // lead and the context read as one
                                      // string - his words were that the job
                                      // label and the information after it
                                      // were hard to tell apart. One weight
                                      // step at 13px is not a separator.
                                      //
                                      // Colour carries it instead: textPrimary
                                      // against textSecondary is 19.4:1 against
                                      // 6.01:1 on this canvas, which is the
                                      // strongest separation available for
                                      // ZERO width - and width is the whole
                                      // constraint on this line. A middle-dot
                                      // separator was the runner-up and was
                                      // rejected here for costing ~10px, about
                                      // 11% of the line, on rows whose context
                                      // is already ellipsising.
                                      //
                                      // That argument got STRONGER on
                                      // 2026-08-07, not weaker. The line is
                                      // 113.0px and the longest lead it now
                                      // draws is `Processing job` at 103.6px
                                      // (measured w600), leaving 9.4px - so a
                                      // separator costing ~10px would clip the
                                      // very row the wording was restored for.
                                      //
                                      // It does not fight the token title
                                      // above: that is 15px w600 and this is
                                      // 13px, so the size step keeps the
                                      // hierarchy. Named fallback if white
                                      // reads too hot on the second line: white
                                      // at 70%, still well clear of AA.
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: gw.textPrimary,
                                      ),
                                    ),
                                  if (content.subtitleBase.isNotEmpty)
                                    TextSpan(
                                      text: content.subtitleLead == null
                                          ? content.subtitleBase
                                          : ' ${content.subtitleBase}',
                                    ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              // `fontSize: compact ? 11` is develop's
                              // phone-width shrink (260806-hfe), carried across
                              // this merge. It buys back line width, which is
                              // exactly the currency the lead-plus-context
                              // paragraph below is short of - the two changes
                              // pull the same way rather than against.
                              style: GeniusWalletTypography.bodySm.copyWith(
                                fontSize: compact ? 11 : null,
                                color: gw.textSecondary,
                              ),
                            ),
                          ),
                          // The status, pinned right. WIDE-SUPPRESSED and nothing
                          // else is: the page states the status in its pill, so
                          // drawing the tail there would say it twice - and
                          // gating the whole subtitle on `wide` instead would
                          // lose it on the panel entirely.
                          if (!wide && content.statusTail != null) ...[
                            const SizedBox(width: GeniusWalletConsts.space2),
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: _narrowStatusMaxWidth,
                              ),
                              child: Text(
                                content.statusTail!,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                // Same shrink as the paragraph beside it. If
                                // only one of the two shrank, the subtitle
                                // would print at two sizes on one line.
                                style: GeniusWalletTypography.bodySm.copyWith(
                                  fontSize: compact ? 11 : null,
                                  color: gw.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Right side.
                //
                // WIDE page (sketch 030-A2): a Status pill, then a fixed
                // `space6` (12px, the same gap as time↔coin) gap, then a
                // fixed-width amount column. Because the amount column is a fixed
                // width sitting flush right and `Expanded` above absorbs all the
                // slack, the pill's right edge lands on ONE vertical line a
                // constant space6 off the amount — "every status respects one
                // place", whatever the label's width.
                //
                // NARROW panel: the amount takes an `Expanded` (tight) so it
                // right-aligns to the card edge and ellipsises when the row is
                // genuinely narrow (the 320px case) instead of overflowing; no
                // pill — the status stays folded into the subtitle there.
                //
                // Neither branch derives a dimension from constraints; the split
                // is one boolean and the amount width is a constant (37639d5).
                if (wide) ...[
                  const SizedBox(width: GeniusWalletConsts.space6),
                  _statusPill(content.status, gw, label: content.statusLabel),
                  const SizedBox(width: GeniusWalletConsts.space6),
                  SizedBox(width: _wideAmountWidth, child: amountColumn),
                ] else ...[
                  const SizedBox(width: GeniusWalletConsts.space4),
                  Expanded(child: amountColumn),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget _buildRow(
  BuildContext context,
  String label,
  String value, {
  Color? valueColor,
}) {
  final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
  return Padding(
    padding: kGWDetailRowPadding,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GeniusWalletTypography.bodySm.copyWith(
            color: gw.textPrimary70,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GeniusWalletTypography.bodyMd.copyWith(
              color: valueColor ?? gw.textPrimary,
            ),
            // maxLines pairs with the ellipsis: without it, `overflow` only
            // trims the LAST wrapped line, so an unbounded model string still
            // grows the drawer row without limit (T-12-02).
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

/// The `·`-grouped short form of an address or a hash - `0x1234·5678 … cdef·0123`.
///
/// Sketch 154-D, borrowing 034-A2's "eyeball verify" treatment: what a person
/// does with an address on screen is compare its ENDS against one they already
/// have. `WalletUtils.getAddressForDisplay` (no longer called here) gives them
/// 6 + 4 characters in two
/// unbroken runs; this gives 8 + 8 in 4-character groups, which is the unit the
/// eye actually checks, and emphasises the two groups that do the verifying.
///
/// **It deliberately does not show the whole value.** A 42-character address
/// chunked in full is ~398px of monospace and this panel's content width is
/// 380; a hash is 66 characters, which no single row can hold at any size.
/// Sketch 154 anticipated exactly this - chunking is *"worth it for an address
/// and arguable for a 64-character hash"*. The full value is what lands in the
/// clipboard, and the clipboard is what the row is for.
List<TextSpan> _valueChunks(String raw, GWColors gw, TextStyle base) {
  final v = raw.trim();
  final prefix = (v.length > 2 && v.toLowerCase().startsWith('0x'))
      ? v.substring(0, 2)
      : '';
  final body = v.substring(prefix.length);

  final strong = base.copyWith(
    color: gw.textPrimary,
    fontWeight: FontWeight.w600,
  );
  final quiet = base.copyWith(color: gw.textSecondary);

  List<String> groupsOf(String s) => [
    for (var i = 0; i < s.length; i += 4)
      s.substring(i, i + 4 > s.length ? s.length : i + 4),
  ];

  // Short enough to print whole - a chain symbol, a short reference. Every
  // group shows; the ends still carry the emphasis.
  if (body.length <= 16) {
    final g = groupsOf(body);
    return [
      if (prefix.isNotEmpty) TextSpan(text: prefix, style: quiet),
      for (var i = 0; i < g.length; i++) ...[
        if (i > 0) TextSpan(text: '·', style: quiet),
        TextSpan(
          text: g[i],
          style: (i == 0 || i == g.length - 1) ? strong : quiet,
        ),
      ],
    ];
  }

  final head = groupsOf(body.substring(0, 8));
  final tail = groupsOf(body.substring(body.length - 8));
  return [
    if (prefix.isNotEmpty) TextSpan(text: prefix, style: quiet),
    TextSpan(text: head[0], style: strong),
    TextSpan(text: '·', style: quiet),
    TextSpan(text: head[1], style: quiet),
    TextSpan(text: ' … ', style: quiet),
    TextSpan(text: tail[0], style: quiet),
    TextSpan(text: '·', style: quiet),
    TextSpan(text: tail[1], style: strong),
  ];
}

/// A detail row whose value belongs in the clipboard rather than on screen.
///
/// Sketch 154-D's whole premise: this drawer is opened *"to get the hash or the
/// address out"*. The glyph is present at rest rather than appearing on hover -
/// an affordance nobody can see until they hover over it is not an affordance -
/// and hover only brightens it, so nothing moves and the row never reflows.
///
/// `HitTestBehavior.opaque` makes the whole row the target, not just the
/// painted glyph: the panel gives us 380px of width and there is no reason to
/// hand the user a 14px one.
class _CopyRow extends StatelessWidget {
  const _CopyRow({required this.label, required this.value});

  final String label;

  /// The FULL value. What is drawn is [_valueChunks]' short form; what is
  /// copied is this.
  final String value;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    // The address treatment already used by the account drawers: bodySm in
    // the shared mono token (GeniusWalletTypography.monoFamily).
    final mono = GeniusWalletTypography.bodySm.copyWith(
      fontFamily: GeniusWalletTypography.monoFamily,
    );

    // Hover plumbing moved into `GWHoverable` (23-05); this widget held no
    // other state, so it is a `StatelessWidget` now.
    return GWHoverable(
      builder: (hovered) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Clipboard.setData(ClipboardData(text: value));
          showToast(context, '$label copied');
        },
        // The inset is INSIDE the detector, so the whole grid cell is the
        // target -- see kGWDetailRowPadding for why the grid does not pad.
        child: Padding(
          padding: kGWDetailRowPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GeniusWalletTypography.bodySm.copyWith(
                  color: gw.textPrimary70,
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text.rich(
                        TextSpan(children: _valueChunks(value, gw, mono)),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: GeniusWalletConsts.space3),
                    Icon(
                      Icons.copy_rounded,
                      size: 14,
                      color: hovered ? gw.textPrimary : gw.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ONE detail drawer for all seven types, replacing the three divergent
/// `_show*TransactionDetails` methods.
///
/// The four optional parameters are how a caller whose source carries MORE
/// than a `Transaction` can hold (a Banxa order: a payment method, a fiat
/// pair, two fiat fees, an order id) reaches this drawer instead of writing a
/// lookalike. Each defaults to today's behaviour exactly:
///   - [contentOverride] null -> the price-map derivation, as before.
///   - the two extras lists empty -> the emitted rows are byte-identical to
///     today's, which is why `transactions_slim_view.dart`, `swap_screen.dart`,
///     `bridge_screen.dart` and `dev_tools_bubble.dart` are untouched.
///   - [footer] null -> the View on Explorer button, as before.
///
/// The extras are [TxDetailRow] DATA and are rendered through this function's
/// own `add`/`addCopy` closures, so a value the source did not provide is
/// dropped rather than printed as an empty row - the caller writes no
/// null-guards. Nothing Banxa-shaped is imported here; the mapping lives in
/// `lib/banxa/banxa_helpers/order_transaction_mapping.dart`.
void showTransactionDetails(
  BuildContext context,
  Transaction tx, {
  TxRowContent? contentOverride,
  List<TxDetailRow> extraTransactionRows = const [],
  List<TxDetailRow> extraNetworkRows = const [],
  Widget? footer,
}) {
  final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
  final content =
      contentOverride ?? txRowContent(tx, prices: livePricesBySymbol());
  final status = tx.transactionStatus;
  // `isDead` is gone with it: the Status row's colour no longer comes from a
  // failed/cancelled test here, it comes from txStatusColors like the pill's.
  final isSent = tx.transactionDirection == TransactionDirection.sent;
  final isSwap = tx.type == TransactionType.swap;

  // Two lists, not one: sketch 154-A groups the rows into TRANSACTION and
  // NETWORK, and the grouping is the design rather than a decoration on top of
  // it.
  final txRows = <Widget>[];
  final netRows = <Widget>[];

  void add(List<Widget> into, String label, String value, {Color? valueColor}) {
    if (value.trim().isEmpty) {
      return;
    }
    into.add(_buildRow(context, label, value, valueColor: valueColor));
  }

  void addCopy(List<Widget> into, String label, String value) {
    if (value.trim().isEmpty) {
      return;
    }
    into.add(_CopyRow(label: label, value: value.trim()));
  }

  // `.toLocal()` on every type. The old `TransactionItem` drawer formatted the
  // raw UTC stamp while the other two localised it — same field, two answers.
  add(txRows, 'Date', _dateFormat.format(tx.timeStamp.toLocal()));
  // The pill's own colour, from the same function -- see txStatusColors for
  // the two rules this replaces.
  add(
    txRows,
    'Status',
    content.statusLabel ?? _capitalizeStatus(status),
    valueColor: txStatusColors(status, gw).fg,
  );
  // 154-A: "the exact number belongs on a receipt". `exactAmount` is non-null
  // ONLY when the headline lost precision, so this row appears exactly when
  // there is something the headline is not telling you.
  if (content.exactAmount != null) {
    add(txRows, 'Exact amount', content.exactAmount!);
  }

  if (isSwap) {
    // A swap's counterparty is a router contract, not a person, and its
    // "From"/"To" labels would collide with the address row's — so the pairs
    // take those labels and the address row is dropped for this type. These
    // are amounts, not addresses: plain rows, nothing to copy.
    add(
      txRows,
      'From',
      '${formatTxAmount(tx.fromAmount ?? '')} ${tx.fromSymbol ?? ''}',
    );
    add(
      txRows,
      'To',
      '${formatTxAmount(tx.toAmount ?? '')} ${tx.toSymbol ?? ''}',
    );
    add(txRows, 'Rate', tx.exchangeRate ?? '');
  } else {
    final counterparty = isSent
        ? (tx.recipients.isEmpty ? '' : tx.recipients.first.toAddr)
        : tx.fromAddress;
    // 154-D: the FULL address goes to the row, which prints its short chunked
    // form and copies the whole thing. `getAddressForDisplay` is deliberately
    // not called here any more — it would have truncated the value before the
    // clipboard ever saw it.
    addCopy(txRows, isSent ? 'To' : 'From', counterparty);
  }

  // Caller-supplied extras, APPENDED after the base rows. Empty by default,
  // so every existing call site emits exactly what it emitted before.
  void addExtras(List<Widget> into, List<TxDetailRow> extras) {
    for (final row in extras) {
      if (row.copy) {
        addCopy(into, row.label, row.value);
      } else {
        add(into, row.label, row.value);
      }
    }
  }

  addExtras(txRows, extraTransactionRows);

  add(netRows, 'Network', tx.coinSymbol);
  // Where the fee lives now that it is off the resting row. A blank `fees`
  // means "no fee is known" (e.g. the D-01 unwired swap path) - skip the row
  // entirely, exactly as the Rate row above already skips a blank
  // `exchangeRate`. Do not "restore" this for a value that composes to a bare
  // coin symbol; that IS the defect this guard closes.
  if (tx.fees.trim().isNotEmpty) {
    add(netRows, 'Network Fee', '${formatTxAmount(tx.fees)} ${tx.coinSymbol}');
  }
  // Network extras are INSERTED here, above the hash: the hash is the group's
  // terminal identifier and the explorer footer's subject. With the default
  // empty list this loop emits nothing and the row order below is unchanged.
  addExtras(netRows, extraNetworkRows);
  // For a processing job the hash IS the job reference — one row, not the same
  // value printed twice under two labels.
  addCopy(
    netRows,
    tx.type == TransactionType.process ? 'Job' : 'Hash',
    tx.hash,
  );

  final explorerUrl = getExplorerUrl(tx.coinSymbol, tx.hash);

  ResponsiveDrawer.show(
    context: context,
    title: content.action,
    child: ListView(
      children: [
        const SizedBox(height: GeniusWalletConsts.space8),
        Center(child: _identity(content, gw, size: 60)),
        const SizedBox(height: GeniusWalletConsts.space6),
        Center(
          child: Text(
            content.amount,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GeniusWalletTypography.numericHeadline.copyWith(
              color: _toneColor(content.tone, gw),
            ),
          ),
        ),
        // The fiat line. Already computed on this call and dropped by the
        // shipped drawer, which is the defect sketch 154 opened with. Null
        // means an unpriced coin, and then no line is printed rather than a
        // fabricated `$0.00`.
        if (content.valueLine != null) ...[
          const SizedBox(height: GeniusWalletConsts.space2),
          Center(
            child: Text(
              content.valueLine!,
              style: GeniusWalletTypography.bodyMd.copyWith(
                color: gw.textSecondary,
              ),
            ),
          ),
        ],
        const SizedBox(height: GeniusWalletConsts.space6),
        // `_statusPill` was written, correct for all four states, and used only
        // on wide rows. The amount stays neutral on purpose (031 round 2): the
        // colour rides on the icon badge, this pill and the Status row.
        Center(child: _statusPill(status, gw, label: content.statusLabel)),
        const SizedBox(height: GeniusWalletConsts.space12),

        // A kicker over a ruled well, which is 154-A's grouping restored
        // (Jakub, 2026-07-28: that grid is missing and he wanted it back). The
        // first pass shipped the rows bare on 067-A's reasoning; see
        // `GWDetailGrid`'s doc for why that reasoning covers a box around a
        // FORM and not a read-only table, and why `borderSubtle` rather than
        // the white 36% a form's frame would need.
        const GWKicker('Transaction'),
        const SizedBox(height: GeniusWalletConsts.space4),
        GWDetailGrid(rows: txRows),
        const SizedBox(height: GeniusWalletConsts.space10),
        const GWKicker('Network'),
        const SizedBox(height: GeniusWalletConsts.space4),
        GWDetailGrid(rows: netRows),
      ],
    ),
    // A caller-supplied footer REPLACES the explorer button rather than
    // stacking above it: the callers that supply one have no settled hash, so
    // there is no explorer URL to lose, and two full-width `lg` buttons in a
    // drawer footer is not a pattern this app has anywhere.
    //
    // Suppressed rather than rendered dead: on a chain missing from
    // `explorerMap` the old button opened nothing at all.
    footer:
        footer ??
        (explorerUrl.isEmpty
            ? null
            : GWButton(
                onPressed: () {
                  final uri = Uri.tryParse(explorerUrl);
                  if (uri?.scheme.startsWith('http') ?? false) {
                    launchWebSite(context, uri.toString());
                  }
                },
                label: 'View on Explorer',
                leading: const Icon(Icons.open_in_new),
                // gradientOutline, not secondary (Jakub, 2026-07-28): this is the
                // panel's ONLY action, so it carries the brand signature — hollow,
                // because opening a block explorer commits to nothing.
                variant: GWButtonVariant.gradientOutline,
                // lg = 56, matching Swap Settings' Apply and both account drawers.
                // Without it this took the `md` default and was the ONE drawer
                // footer in the app 8px shorter than its neighbours.
                size: GWButtonSize.lg,
                expand: true,
              )),
  );
}
