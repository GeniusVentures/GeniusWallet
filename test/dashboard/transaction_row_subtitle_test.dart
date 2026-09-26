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

/// A 390pt phone's `/transactions` content box: 366 - 2*space6 padding - 44
/// time - space6 - 38 identity - space6 leaves 236, which the subtitle column
/// shares with the space4 gutter and the amount at its natural width.
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
            // a completed row) OR the line can hold the lead plus the ellipsis
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

      // …and the line still has room for the VERB ITSELF, plus its ellipsis,
      // once the tail and its space2 gutter are taken. `Minted` 48.5 + `…` 12.3
      // = 60.8px. The line was 54.1px while the amount column took a fixed half
      // of the row; with `- 1.25 ETH` at its natural width it is 79.2px.
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
      expect(
        lead + ellipsis,
        lessThanOrEqualTo(available),
        reason:
            'the verb no longer survives a pending mint. Line '
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
        final word = statusWordFor(status);
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
  // with the whole line. It says nothing about the other three statuses,
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
    // THE BOXES. The amount keeps its natural width and the name block takes
    // the rest, so the paragraph's box is that remainder less `space2` (4) and
    // the status tail. It differs per row: a wide amount (a swap's
    // `+ 2,400.75 GNUS`) leaves far less than a short one (`- 1.25 ETH`).
    // The table `tearDownAll` prints has every box.
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
    // `Processing job` only where the whole line exists (no tail), and keeps
    // the short `Job` (26.1, drawn whole in even the 34.9px a cancelled job row
    // leaves) everywhere a status tail narrows it. The job row is the ONE type
    // that clips nothing at any status, and that is the whole point of the
    // hybrid. If a `process` entry ever needs adding here, the hybrid stopped
    // delivering what it promised - stop and re-read the `process` arm of
    // `txRowContent` rather than widening this list.
    const leadCutAllowlist = <String>{
      // `Released` 64.1 + 12.3 = 76.4 misses the two narrowest tails.
      'escrowRelease/sent/cancelled',
      'escrowRelease/sent/refunded',
      'escrowRelease/received/cancelled',
      'escrowRelease/received/refunded',
      // `Card purchase` 102.4 + 12.3 = 114.7. The longest lead the row can
      // draw, and the only one that is the ENTIRE paragraph - `purchase` has no
      // qualifier, so there is nothing in front of the verb to give way first.
      'purchase/sent/cancelled',
      'purchase/sent/failed',
      'purchase/sent/needsGas',
      'purchase/sent/partialSuccess',
      'purchase/sent/pending',
      'purchase/sent/refunded',
      'purchase/received/cancelled',
      'purchase/received/failed',
      'purchase/received/needsGas',
      'purchase/received/partialSuccess',
      'purchase/received/pending',
      'purchase/received/refunded',
      // A swap's `+ 2,400.75 GNUS` is the widest amount here, and the amount
      // wins: `Swapped` gives way at every status that draws a tail.
      'swap/sent/cancelled',
      'swap/sent/failed',
      'swap/sent/needsGas',
      'swap/sent/partialSuccess',
      'swap/sent/pending',
      'swap/sent/refunded',
      'swap/received/cancelled',
      'swap/received/failed',
      'swap/received/needsGas',
      'swap/received/partialSuccess',
      'swap/received/pending',
      'swap/received/refunded',
      // `Received` 64.3 + 12.3 = 76.6 misses the two narrowest tails.
      'transfer/received/cancelled',
      'transfer/received/refunded',
      // The untyped row draws the same verbs as `transfer`, so it clips in the
      // same places.
      'null/received/cancelled',
      'null/received/refunded',
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

      // A COMPLETED job row has the whole line - no status tail - and the full
      // wording fits it: 107.2px once the fee amount beside it takes its own
      // width. This is what dropping the hash bought.
      expect(
        full,
        lessThan(rp.size.width),
        reason:
            '"Processing job" measures ${full.toStringAsFixed(1)}px against a '
            '${rp.size.width.toStringAsFixed(1)}px line',
      );

      // …and it fits NO other status. 62.4 is the widest narrowed job box
      // (failed), so failing that fails every other status too.
      expect(
        full + ellipsis,
        greaterThan(62.4),
        reason:
            'if this now passes, the full wording survives a FAILED job row - '
            'widen the hybrid in `txRowContent` and say so here. '
            '"Processing job" ${full.toStringAsFixed(1)}px + '
            '${ellipsis.toStringAsFixed(1)}px of ellipsis against 62.4px',
      );

      // The short word is what makes the hybrid work: it is drawn whole in
      // even the narrowest box, the 34.9px a cancelled job row leaves.
      expect(
        short,
        lessThan(34.9),
        reason:
            '"Job" ${short.toStringAsFixed(1)}px against the 34.9px a '
            'cancelled job row leaves',
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
