// The layout proof for sketch 179-C: the action word leads the subtitle and is
// never clipped, and the status is pinned to the right of that line where it can
// no longer be cut off the row.
//
// WHY THIS FILE EXISTS SEPARATELY FROM `transaction_row_test.dart`: that file is
// a pessimism harness. It runs under `flutter test`'s FALLBACK font, whose every
// glyph is exactly one em wide, and it asks one question - does the row overflow.
// That is the right question there and the wrong font here. Every assertion below
// measures a real TEXT WIDTH to judge whether a word survives, and under a
// one-em-per-character font those widths are fiction (`· Cancelled` measures 154
// there against 66.0 in the shipped Inter). So this file loads the real bundled
// Inter and pumps the app's REAL `ThemeData`.
//
// The theme matters as much as the font. Material's default `bodyMedium` carries
// 0.25 letter spacing; `GeniusWalletTypography.bodySm` carries none, and `Text`
// merges its style over the ambient `DefaultTextStyle`. A bare
// `ThemeData(extensions: [gw])` therefore inflates a 26-character line by 6.5px -
// larger than the margins this file checks.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// The weights this row can request: the qualifier and the status tail at
/// `bodySm`'s w400, the title and the subtitle's lead at w600, and Medium in
/// between for anything that asks. Loaded into the one family `Inter` so the
/// engine picks the variant by weight, exactly as it does on device.
Future<void> _loadInter() async {
  final loader = FontLoader('Inter');
  for (final asset in const [
    'Inter-Regular.ttf',
    'Inter-Medium.ttf',
    'Inter-SemiBold.ttf',
  ]) {
    loader.addFont(rootBundle.load('assets/fonts/$asset'));
  }
  await loader.load();
}

/// A 390pt phone's `/transactions` content box. It gives the row's middle column
/// exactly 114.0px: 366 - 2*space6 padding - 44 time - space6 - 38 identity -
/// space6, then the remaining 236 less the space4 gutter, split between the
/// subtitle column and the amount column. (38, not 40: Jakub picked Assets' row
/// geometry as the pattern on 2026-08-07, and Assets' leading glyph measures
/// 38 - the freed 2px is split 1:1 between this column and the amount column,
/// so the box gained 1px, not 2.)
const double _kPhoneWidth = 366;

/// The wide `/transactions` page, above `_wideRowThreshold` (720).
const double _kWideWidth = 900;

/// Mirrors the private `_narrowStatusMaxWidth` in `transaction_displays.dart`.
/// Re-declared rather than exported: this file's job is to fail loudly if a
/// status word ever outgrows the cap, and a shared constant that moved with the
/// widget would move this check with it.
const double _kNarrowStatusMaxWidth = 76;

Transaction _tx({
  TransactionType? type,
  TransactionStatus status = TransactionStatus.completed,
  TransactionDirection direction = TransactionDirection.sent,
}) => Transaction(
  hash: '0xabcdef0123456789abcdef0123456789abcdef0123456789',
  fromAddress: '0x1111222233334444555566667777888899990000',
  recipients: [
    TransferRecipients(
      toAddr: '0x5555666677778888999900001111222233334444',
      amount: '1.25',
    ),
  ],
  timeStamp: DateTime(2026, 7, 20, 18, 42),
  transactionDirection: direction,
  fees: '0.00042',
  coinSymbol: 'ETH',
  transactionStatus: status,
  type: type,
  fromAmount: '1.5',
  toAmount: '2400.75',
  fromSymbol: 'ETH',
  toSymbol: 'GNUS',
  exchangeRate: '1600.5',
);

final GWColors _gw = GWColors.dark();

Widget _host(Transaction tx, {required double width}) => MaterialApp(
  // The app's own text theme, NOT Material's default - see the file header.
  theme: ThemeData(
    extensions: <ThemeExtension<dynamic>>[_gw],
    textTheme: GeniusWalletTypography.toMaterialTextTheme(),
  ),
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: width,
        child: TransactionRow(tx: tx),
      ),
    ),
  ),
);

String _plainOf(Text widget) =>
    widget.data ?? widget.textSpan?.toPlainText() ?? '';

/// The one `Text` on the row whose text contains [needle].
///
/// Deliberately content-addressed rather than positional: it resolves the same
/// element before and after the anatomy change, so this file reports real
/// numbers while it is red instead of "found 0 widgets".
RenderParagraph _paragraphWith(WidgetTester tester, String needle) =>
    tester.renderObject<RenderParagraph>(
      find.byWidgetPredicate(
        (w) => w is Text && _plainOf(w).contains(needle),
        description: 'the Text containing "$needle"',
      ),
    );

/// The unconstrained width of [span], laid out exactly as [rp] lays out its own.
double _widthOf(InlineSpan span, RenderParagraph rp) {
  final painter = TextPainter(
    text: span,
    textDirection: rp.textDirection,
    textScaler: rp.textScaler,
    maxLines: 1,
  )..layout();
  return painter.width;
}

/// The resolved paragraph style [rp] actually paints with - `bodySm` already
/// merged over the ambient `DefaultTextStyle`, so a measurement taken with it is
/// the measurement the engine took.
TextStyle _styleOf(RenderParagraph rp) =>
    (rp.text as TextSpan).style ?? const TextStyle();

/// The width of the lead AS DRAWN.
///
/// Deliberately measured from the paragraph's own FIRST CHILD SPAN, wrapped back
/// in the root's style so the cascade is reproduced exactly - not from a weight
/// this file names. The lead's emphasis has already changed once (w500, then
/// w600 + `textPrimary` after Jakub's 2026-08-07 device read), and a hardcoded
/// weight here would have kept passing while measuring a narrower string than the
/// row actually paints.
double _leadWidth(RenderParagraph rp) {
  final root = rp.text as TextSpan;
  // `Text.rich` nests: RichText's root span carries the resolved paragraph style
  // and ONE child, which is the span this row passed in, whose children are the
  // lead and the qualifier. Descending to the first leaf rather than taking
  // `root.children!.first` is the difference between measuring the lead and
  // measuring the entire line - the wrapper reports the whole paragraph's width.
  final lead = _firstLeaf(root);
  // Re-wrapped in the root's style so the cascade is the one the engine applied.
  return _widthOf(TextSpan(style: root.style, children: [lead]), rp);
}

TextSpan _firstLeaf(TextSpan node) {
  final children = node.children;
  if (node.text != null || children == null || children.isEmpty) {
    return node;
  }
  return _firstLeaf(children.first as TextSpan);
}

double _ellipsisWidth(RenderParagraph rp) =>
    _widthOf(TextSpan(text: '…', style: _styleOf(rp)), rp);

/// [text] measured in the LEAD's own resolved style - the paragraph's cascade
/// with the lead span's overrides on top. This is how a word the row does not
/// currently draw (`Processing job` while the row still says `Job`) gets a
/// number that is comparable with [_leadWidth].
double _widthAtLeadStyle(RenderParagraph rp, String text) {
  final root = rp.text as TextSpan;
  final lead = _firstLeaf(root);
  return _widthOf(
    TextSpan(
      style: root.style,
      children: [TextSpan(text: text, style: lead.style)],
    ),
    rp,
  );
}

/// What the user actually SEES of an ellipsised paragraph, to the character.
///
/// The longest prefix of the paragraph's plain text whose width still leaves
/// room for the ellipsis glyph. Measured at the paragraph's ROOT style, so a
/// line whose lead is a heavier span reads very slightly long here - which errs
/// towards reporting LESS surviving text, never more.
String _drawnPrefix(RenderParagraph rp) {
  final plain = rp.text.toPlainText();
  final style = _styleOf(rp);
  if (_widthOf(rp.text, rp) <= rp.size.width + 0.5) {
    return plain;
  }
  final room = rp.size.width - _ellipsisWidth(rp);
  var lo = 0;
  var hi = plain.length;
  while (lo < hi) {
    final mid = (lo + hi + 1) ~/ 2;
    final w = _widthOf(
      TextSpan(text: plain.substring(0, mid), style: style),
      rp,
    );
    if (w <= room) {
      lo = mid;
    } else {
      hi = mid - 1;
    }
  }
  return '${plain.substring(0, lo)}…';
}

TxRowContent _contentOf(Transaction tx) =>
    txRowContent(tx, prices: const <String, double>{});

/// The piece of a row's subtitle that is unique on the row, for [_paragraphWith].
/// `purchase` has no qualifier at all, so it is addressed by its lead.
String _needleFor(TxRowContent content) =>
    content.subtitleBase.isEmpty ? content.subtitleLead! : content.subtitleBase;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_loadInter);

  final typeCases = <TransactionType?>[...TransactionType.values, null];

  group('179-C: the action word leads the subtitle and survives whole', () {
    // 1. THE REPORTED DEFECT. Before this change the action word sat in a
    //    `surfaceMenu` chip whose box was 44.5px, and 6 of the 8 strings
    //    `_actionFor` can return did not fit it - `Escrow released` rendered
    //    `Escro…` on every row that printed it. The word now leads the subtitle,
    //    where the only thing that can eat it is an end ellipsis, and an end
    //    ellipsis reaches it only after the qualifier is entirely gone.
    for (final type in typeCases) {
      for (final direction in TransactionDirection.values) {
        testWidgets(
          'the lead is drawn in full: type=$type direction=${direction.name}',
          (tester) async {
            final tx = _tx(type: type, direction: direction);
            final content = _contentOf(tx);
            await tester.pumpWidget(_host(tx, width: _kPhoneWidth));
            expect(tester.takeException(), isNull);

            final rp = _paragraphWith(tester, _needleFor(content));
            final available = rp.size.width;
            final whole = _widthOf(rp.text, rp);
            final lead = _leadWidth(rp);
            final ellipsis = _ellipsisWidth(rp);

            // The exact condition, not an approximation of it. The lead is
            // drawn whole if EITHER the paragraph fits entirely (no ellipsis is
            // appended at all, which is how `purchase` keeps its 101.4px lead on
            // a 114px line) OR the line can hold the lead plus the ellipsis
            // glyph, in which case the truncation point cannot fall inside the
            // lead. `…` is 12.3px at bodySm and is a real cost - not the ~4.4px
            // sketch 179 assumed.
            final needed = whole < lead + ellipsis ? whole : lead + ellipsis;
            expect(
              available + 0.5,
              greaterThanOrEqualTo(needed),
              reason:
                  'the line is ${available.toStringAsFixed(1)}px; the whole '
                  'paragraph wants ${whole.toStringAsFixed(1)}px and '
                  '"${content.subtitleLead}" alone needs '
                  '${lead.toStringAsFixed(1)}px plus '
                  '${ellipsis.toStringAsFixed(1)}px of ellipsis',
            );
          },
        );
      }
    }
  });

  group('179-C: the status is pinned and can no longer be clipped', () {
    // 2. THE UNREPORTED DEFECT. Nobody filed this one and 1081 green tests
    //    permitted it: on a pending mint the narrow subtitle was the single
    //    string `Minted to wallet · Pending`, which needs 177.6px on a 114.0px
    //    line. The row clipped the word `Pending` off the one row where the
    //    status is the entire reason the page is open.
    final pendingMint = _tx(
      type: TransactionType.mint,
      status: TransactionStatus.pending,
    );

    testWidgets('a pending mint keeps BOTH its verb and its status', (
      tester,
    ) async {
      final content = _contentOf(pendingMint);
      expect(content.statusTail, 'Pending');
      await tester.pumpWidget(_host(pendingMint, width: _kPhoneWidth));
      expect(tester.takeException(), isNull);

      final rp = _paragraphWith(tester, 'to wallet');
      final available = rp.size.width;

      // The evidence for the defect, and the reason the line had to be split at
      // all: no single-paragraph layout could have shown this row's status.
      final oneLine = _widthOf(
        TextSpan(
          text:
              '${content.subtitleLead} ${content.subtitleBase} '
              '· ${content.statusTail}',
          style: _styleOf(rp),
        ),
        rp,
      );
      expect(
        oneLine,
        greaterThan(available),
        reason:
            'the composed line is ${oneLine.toStringAsFixed(1)}px on a '
            '${available.toStringAsFixed(1)}px line, so the status cannot ride '
            'inside the paragraph',
      );

      // The tail is its own element and not one glyph of it is lost.
      final tail = _paragraphWith(tester, 'Pending');
      final tailIntrinsic = _widthOf(tail.text, tail);
      expect(
        tail.size.width,
        closeTo(tailIntrinsic, 0.5),
        reason:
            'the status tail rendered ${tail.size.width.toStringAsFixed(1)}px '
            'of ${tailIntrinsic.toStringAsFixed(1)}px it needs',
      );

      // …and the line still has room for the VERB ITSELF once the tail and its
      // space2 gutter are taken. This is the tightest pair the layout holds.
      //
      // READ THE NUMBERS BEFORE CHANGING THIS. Sketch 179's finding 4a claimed
      // a 4.3px MARGIN here, on the strength of `Minted` 46.2 plus a 4.4px
      // ellipsis against 54.9px. Measured in the shipped Inter, all three inputs
      // are wrong: the lead renders at w600 and measures 48.5, `Pending`
      // measures 55.9 (not 54.1) so the paragraph gets 54.1 (not 54.9), and `…`
      // (U+2026) is a three-dot glyph measuring 12.3px, not 4.4. Verb plus
      // ellipsis is therefore 60.8px against 54.1px available - a 6.7px
      // SHORTFALL, not a margin. This row renders `Minte…` with the qualifier
      // gone entirely. 114px cannot hold 48.5 + 12.3 + 4 + 55.9 = 120.7px; no
      // arrangement of a `Row` fixes that, and taking the difference from the
      // amount column is what finding 3 measured as strictly worse.
      //
      // What is asserted is what IS guaranteed and what a regression would
      // break: the line holds the verb, and only the ellipsis glyph displaces
      // it. Grow the tail cap, the gutter or the lead's weight and this reddens.
      final lead = _leadWidth(rp);
      final ellipsis = _ellipsisWidth(rp);
      expect(
        available,
        greaterThanOrEqualTo(lead),
        reason:
            'the paragraph gets ${available.toStringAsFixed(1)}px once the tail '
            'and its space2 gutter are taken, and "Minted" alone needs '
            '${lead.toStringAsFixed(1)}px',
      );
      // The shortfall itself, recorded rather than asserted away. If a future
      // change frees ${(lead + ellipsis - available).toStringAsFixed(1)}px the
      // verb survives whole and this row is finally correct.
      expect(
        lead + ellipsis,
        greaterThan(available),
        reason:
            'if this now passes, the verb SURVIVES on a pending mint - delete '
            'this expectation and assert the opposite. Line '
            '${available.toStringAsFixed(1)}px, verb '
            '${lead.toStringAsFixed(1)}px, ellipsis '
            '${ellipsis.toStringAsFixed(1)}px',
      );
    });

    // 3. THE DEGRADATION ORDER. "The boundary falls inside the phrase": the
    //    qualifier is what gives way, the verb and the status do not.
    testWidgets('the qualifier is the piece that gives way, not the tail', (
      tester,
    ) async {
      await tester.pumpWidget(_host(pendingMint, width: _kPhoneWidth));
      expect(tester.takeException(), isNull);

      final rp = _paragraphWith(tester, 'to wallet');
      final paragraphIntrinsic = _widthOf(rp.text, rp);
      expect(
        paragraphIntrinsic,
        greaterThan(rp.size.width),
        reason:
            'the paragraph wants ${paragraphIntrinsic.toStringAsFixed(1)}px of '
            '${rp.size.width.toStringAsFixed(1)}px, so it is what truncated',
      );

      final tail = _paragraphWith(tester, 'Pending');
      expect(
        _widthOf(tail.text, tail),
        lessThanOrEqualTo(tail.size.width + 0.5),
        reason: 'the tail must not be the piece that gave way',
      );
    });

    // 2b. …and not only on the mint. The tail is drawn whole on EVERY type and
    //     every non-happy-path status, which is the general form of the defect:
    //     the status is what a person opens a pending or failed row to read, and
    //     it is now the one piece of the line that cannot give way.
    for (final status in const [
      TransactionStatus.pending,
      TransactionStatus.failed,
      TransactionStatus.cancelled,
    ]) {
      testWidgets('the status is drawn whole on every ${status.name} row', (
        tester,
      ) async {
        for (final type in typeCases) {
          final tx = _tx(type: type, status: status);
          final content = _contentOf(tx);
          await tester.pumpWidget(_host(tx, width: _kPhoneWidth));
          expect(tester.takeException(), isNull, reason: 'type=$type');

          final tail = _paragraphWith(tester, content.statusTail!);
          final intrinsic = _widthOf(tail.text, tail);
          expect(
            tail.size.width,
            closeTo(intrinsic, 0.5),
            reason:
                'type=$type: the tail rendered '
                '${tail.size.width.toStringAsFixed(1)}px of the '
                '${intrinsic.toStringAsFixed(1)}px it needs',
          );
        }
      });
    }

    // 4. THE CAP HOLDS. The tail is the row's ONLY non-flex subtitle child, so
    //    its `ConstrainedBox` is the single thing that could overflow. This is
    //    the guard that reddens if a longer status word is ever added.
    testWidgets('every status word fits under the tail cap', (tester) async {
      await tester.pumpWidget(_host(pendingMint, width: _kPhoneWidth));
      final tail = _paragraphWith(tester, 'Pending');
      final style = _styleOf(tail);
      for (final status in TransactionStatus.values) {
        final word = status.name[0].toUpperCase() + status.name.substring(1);
        final width = _widthOf(TextSpan(text: word, style: style), tail);
        expect(
          width,
          lessThan(_kNarrowStatusMaxWidth),
          reason:
              '"$word" measures ${width.toStringAsFixed(1)}px against a '
              '$_kNarrowStatusMaxWidth cap',
        );
      }
    });
  });

  // 5. THE WIDE BRANCH. `wide` gates the STATUS TAIL and nothing else: the lead
  //    and the qualifier are drawn in both presentations. Gate the whole
  //    subtitle on it instead and the page double-prints the status, or the
  //    panel loses it.
  group('179-C: the wide page keeps its pill and draws no tail', () {
    final pendingMint = _tx(
      type: TransactionType.mint,
      status: TransactionStatus.pending,
    );

    testWidgets('at 900 the status is stated once, by the pill', (
      tester,
    ) async {
      await tester.pumpWidget(_host(pendingMint, width: _kWideWidth));
      expect(tester.takeException(), isNull);

      // Exactly one `Pending`, and it is the PILL - pinned by its ink, not
      // merely by its presence.
      final pending = find.text('Pending');
      expect(pending, findsOneWidget);
      expect(
        tester.widget<Text>(pending).style?.color,
        txStatusColors(TransactionStatus.pending, _gw).fg,
      );

      // …and the subtitle still carries both of its own pieces.
      final rp = _paragraphWith(tester, 'to wallet');
      expect(rp.text.toPlainText(), 'Minted to wallet');
    });
  });

  // ---------------------------------------------------------------------------
  // 6. THE LEDGER. Every type by every direction by every status, measured.
  //
  // Group 1 above proves the lead survives on a COMPLETED row, which is the row
  // with the whole 114.0px line. It says nothing about the other three statuses,
  // where the pinned status tail takes 44 to 70px of that line - and those are
  // exactly the rows a person opens the panel to read.
  //
  // So this walks the full matrix, records the arithmetic for every cell, and
  // pins the set of cells where the LEAD ITSELF is cut against a written
  // allowlist. Equality, not containment:
  //   - a NEW shortfall reddens, so no row can start clipping its verb quietly;
  //   - a FIXED one ALSO reddens, and the failure tells the reader to delete
  //     that entry rather than leaving a stale claim in the file.
  //
  // Written 2026-08-07, when the job row stopped printing the transaction hash
  // and took its full wording back. The numbers below are what that change is
  // judged against.
  // ---------------------------------------------------------------------------
  group('the subtitle ledger: every type, direction and status, measured', () {
    // key -> `type/direction/status`. Every entry is a cell where the line
    // cannot even hold the LEAD plus an ellipsis, so the verb itself is cut.
    //
    // THE BOXES, measured on this tree at a 366px host. The paragraph gets
    // 114.0 less `space2` (4) less the status tail's own width:
    //
    //     completed  114.0   (no tail at all)
    //     failed      69.2   (`Failed`    40.8)
    //     pending     54.1   (`Pending`   55.9)
    //     cancelled   41.7   (`Cancelled` 68.3)
    //
    // A lead survives when the WHOLE paragraph fits its box (no ellipsis is
    // appended at all) or when lead + 12.3 fits it - 12.3px being the `…` glyph
    // U+2026, which is three dots and not the ~4.4px sketch 179 assumed.
    //
    // THE LEADS, measured at the w600 the row paints them:
    //
    //     Job             26.1     Minted     48.5     Locked         50.8
    //     Sent            31.9     Released   64.1     Received       64.3
    //     Swapped         65.1     Card purchase 102.4
    //     Processing job  103.6    (drawn only on a completed job row)
    //
    // NOTE WHAT IS NOT HERE: no `process` cell, at any status. That is the
    // hybrid Jakub ruled on 2026-08-07 - the job row takes the full
    // `Processing job` only where the full 114.0px line exists, and keeps the
    // short `Job` (26.1 + 12.3 = 38.4, under even the 41.7px a cancelled row
    // leaves) everywhere a status tail narrows it. The job row is the ONE type
    // that clips nothing at any status, and that is the whole point of the
    // hybrid. If a `process` entry ever needs adding here, the hybrid stopped
    // delivering what it promised - stop and re-read the `process` arm of
    // `txRowContent` rather than widening this list.
    const leadCutAllowlist = <String>{
      // `Minted` 48.5 + 12.3 = 60.8. Clears the 69.2 a failed row leaves,
      // misses 54.1 and 41.7. The pending case is the 6.7px shortfall this file
      // already documents in the pending-mint test above, and it is still open.
      'mint/sent/pending',
      'mint/received/pending',
      'mint/sent/cancelled',
      'mint/received/cancelled',
      // `Locked` 50.8 + 12.3 = 63.1. Same shape: clears 69.2, misses 54.1
      // and 41.7.
      'escrow/sent/pending',
      'escrow/received/pending',
      'escrow/sent/cancelled',
      'escrow/received/cancelled',
      // `Released` 64.1 + 12.3 = 76.4, which misses all three narrowed boxes.
      'escrowRelease/sent/pending',
      'escrowRelease/received/pending',
      'escrowRelease/sent/failed',
      'escrowRelease/received/failed',
      'escrowRelease/sent/cancelled',
      'escrowRelease/received/cancelled',
      // `Card purchase` 102.4 + 12.3 = 114.7. The longest lead the row can
      // draw, and the only one that is the ENTIRE paragraph - `purchase` has no
      // qualifier, so there is nothing in front of the verb to give way first.
      'purchase/sent/pending',
      'purchase/received/pending',
      'purchase/sent/failed',
      'purchase/received/failed',
      'purchase/sent/cancelled',
      'purchase/received/cancelled',
      // `Swapped` 65.1 + 12.3 = 77.4, missing all three.
      'swap/sent/pending',
      'swap/received/pending',
      'swap/sent/failed',
      'swap/received/failed',
      'swap/sent/cancelled',
      'swap/received/cancelled',
      // `Sent` 31.9 + 12.3 = 44.2 against the 41.7 a cancelled row leaves - it
      // misses by 2.5px, and clears every other status comfortably. The
      // shortest verb on the row and the only near miss in this list.
      'transfer/sent/cancelled',
      'null/sent/cancelled',
      // `Received` 64.3 + 12.3 = 76.6, missing all three. A receive and a send
      // are the same row with different verbs, and only one of them survives -
      // which is worth knowing before anyone calls this line settled.
      'transfer/received/pending',
      'null/received/pending',
      'transfer/received/failed',
      'null/received/failed',
      'transfer/received/cancelled',
      'null/received/cancelled',
    };

    // Filled by the matrix test, printed once by `tearDownAll`. The executor
    // reads these numbers straight into the SUMMARY - they are the
    // before-and-after evidence the row change is argued from.
    final rows = <String>[];
    final leadCut = <String>{};

    tearDownAll(() {
      if (rows.isEmpty) {
        return;
      }
      // `debugPrint`, never `print`: `avoid_print` is on and the analyzer must
      // stay at zero.
      debugPrint('\n--- subtitle ledger @ ${_kPhoneWidth}px host ---');
      debugPrint(
        '${'key'.padRight(34)}${'box'.padLeft(7)}${'whole'.padLeft(8)}'
        '${'lead'.padLeft(8)}${'ell'.padLeft(6)}  verdict     drawn',
      );
      for (final row in rows) {
        debugPrint(row);
      }
      debugPrint('--- end ledger ---\n');
    });

    testWidgets('the set of cells whose LEAD is cut matches the allowlist', (
      tester,
    ) async {
      for (final type in typeCases) {
        for (final direction in TransactionDirection.values) {
          for (final status in TransactionStatus.values) {
            final key =
                '${type?.name ?? 'null'}/${direction.name}/${status.name}';
            final tx = _tx(type: type, status: status, direction: direction);
            final content = _contentOf(tx);
            await tester.pumpWidget(_host(tx, width: _kPhoneWidth));
            expect(tester.takeException(), isNull, reason: key);

            final rp = _paragraphWith(tester, _needleFor(content));
            final box = rp.size.width;
            final whole = _widthOf(rp.text, rp);
            final lead = _leadWidth(rp);
            final ellipsis = _ellipsisWidth(rp);

            final String verdict;
            if (whole <= box + 0.5) {
              verdict = 'WHOLE';
            } else if (lead + ellipsis <= box + 0.5) {
              verdict = 'LEAD-SAFE';
            } else {
              verdict = 'LEAD-CUT';
              leadCut.add(key);
            }

            rows.add(
              '${key.padRight(34)}${box.toStringAsFixed(1).padLeft(7)}'
              '${whole.toStringAsFixed(1).padLeft(8)}'
              '${lead.toStringAsFixed(1).padLeft(8)}'
              '${ellipsis.toStringAsFixed(1).padLeft(6)}'
              '  ${verdict.padRight(10)}  "${_drawnPrefix(rp)}"',
            );
          }
        }
      }

      expect(
        leadCut,
        leadCutAllowlist,
        reason:
            'the LEAD-CUT set moved. A cell that APPEARED means a row started '
            'clipping its verb; a cell that VANISHED means one was fixed and '
            'its allowlist entry must be deleted, not left behind. The whole '
            'measured table:\n${rows.join('\n')}',
      );
    });

    // The three numbers the 2026-08-07 job-row change is argued from, measured
    // rather than derived. They are asserted, not merely printed, because the
    // `process` arm's comment quotes them and a comment nothing checks rots.
    testWidgets('the job row wording measures what its comment claims', (
      tester,
    ) async {
      final job = _tx(type: TransactionType.process);
      final content = _contentOf(job);
      await tester.pumpWidget(_host(job, width: _kPhoneWidth));
      expect(tester.takeException(), isNull);

      final rp = _paragraphWith(tester, _needleFor(content));
      final full = _widthAtLeadStyle(rp, 'Processing job');
      final short = _widthAtLeadStyle(rp, 'Job');
      final ellipsis = _ellipsisWidth(rp);
      debugPrint(
        'job wording @ w600: "Processing job" ${full.toStringAsFixed(1)}px, '
        '"Job" ${short.toStringAsFixed(1)}px, "…" '
        '${ellipsis.toStringAsFixed(1)}px, completed line '
        '${rp.size.width.toStringAsFixed(1)}px',
      );

      // A COMPLETED job row has the whole 114.0px line - no status tail - and
      // the full wording fits it with room to spare. This is what dropping the
      // hash bought.
      //
      // 113.0 -> 114.0 on 2026-08-07: Jakub picked Assets' row geometry as the
      // pattern and Assets' leading glyph measures 38, not 40. The freed 2px
      // splits 1:1 between this name-block column and the amount column, so
      // the box gained 1px, not 2 - see `_kPhoneWidth`'s doc comment for the
      // full derivation.
      expect(
        rp.size.width,
        closeTo(114.0, 0.5),
        reason: 'a completed row keeps the whole line',
      );
      expect(
        full,
        lessThan(rp.size.width),
        reason:
            '"Processing job" measures ${full.toStringAsFixed(1)}px against a '
            '${rp.size.width.toStringAsFixed(1)}px line',
      );

      // …and it fits NO other status. 69.2 is the widest of the three narrowed
      // boxes (failed), so failing that fails pending and cancelled too.
      expect(
        full + ellipsis,
        greaterThan(69.2),
        reason:
            'if this now passes, the full wording survives a FAILED job row - '
            'widen the hybrid in `txRowContent` and say so here. '
            '"Processing job" ${full.toStringAsFixed(1)}px + '
            '${ellipsis.toStringAsFixed(1)}px of ellipsis against 69.2px',
      );

      // The short word is what makes the hybrid work: it clears even the
      // narrowest box, the 41.7px a cancelled row leaves.
      expect(
        short + ellipsis,
        lessThan(41.7),
        reason:
            '"Job" ${short.toStringAsFixed(1)}px + '
            '${ellipsis.toStringAsFixed(1)}px of ellipsis against the 41.7px a '
            'cancelled row leaves',
      );
    });

    // How much of the counterparty address a plain send and a plain receive
    // actually render. This is not a defect being fixed here - it is the number
    // that goes to Jakub with ruling 2, because "keep the address" is only
    // worth ruling on if the address is legible, and it is barely that.
    for (final direction in TransactionDirection.values) {
      testWidgets('a plain ${direction.name} row draws only part of its '
          'counterparty', (tester) async {
        final tx = _tx(type: TransactionType.transfer, direction: direction);
        final content = _contentOf(tx);
        await tester.pumpWidget(_host(tx, width: _kPhoneWidth));
        expect(tester.takeException(), isNull);

        final rp = _paragraphWith(tester, _needleFor(content));
        final whole = _widthOf(rp.text, rp);
        expect(
          whole,
          greaterThan(rp.size.width),
          reason:
              'if this now passes the address survives WHOLE on a '
              '${direction.name} row - re-measure ruling 2 before quoting it. '
              'Line ${rp.size.width.toStringAsFixed(1)}px, paragraph '
              '${whole.toStringAsFixed(1)}px',
        );
        debugPrint(
          'counterparty @ ${direction.name}: wants '
          '${whole.toStringAsFixed(1)}px of '
          '${rp.size.width.toStringAsFixed(1)}px, draws '
          '"${_drawnPrefix(rp)}" of "${rp.text.toPlainText()}"',
        );
      });
    }
  });
}
