import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_badge.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';

/// Pure unit tests — no `pumpWidget`, no Hive binding, no asset bundle. That is
/// deliberate: sketch 010's diagnosis table is mostly formatting and content
/// decisions, and the whole point of moving them out of `build()` is that they
/// become assertable in under a second.

/// Builds a [Transaction] with everything defaulted, so each test states only
/// the field it is actually about.
Transaction makeTx({
  TransactionType? type,
  TransactionStatus status = TransactionStatus.completed,
  TransactionDirection direction = TransactionDirection.sent,
  String coinSymbol = 'ETH',
  String amount = '0.75',
  String fees = '0.002',
  String hash = '0xabcdef1234567890',
  String fromAddress = '0x1111222233334444',
  String toAddress = '0x5555666677778888',
  List<TransferRecipients>? recipients,
  DateTime? timeStamp,
  String? fromSymbol = 'ETH',
  String? fromAmount = '1.5',
  String? toSymbol = 'GNUS',
  String? toAmount = '1200.5',
}) {
  return Transaction(
    hash: hash,
    fromAddress: fromAddress,
    recipients:
        recipients ?? [TransferRecipients(toAddr: toAddress, amount: amount)],
    timeStamp: timeStamp ?? DateTime(2026, 7, 22, 18, 42),
    transactionDirection: direction,
    fees: fees,
    coinSymbol: coinSymbol,
    transactionStatus: status,
    type: type,
    fromSymbol: fromSymbol,
    fromAmount: fromAmount,
    toSymbol: toSymbol,
    toAmount: toAmount,
  );
}

const emDash = '—';
const minus = '−';

void main() {
  group('formatTxAmount', () {
    test('clamps a 9-decimal whale amount to 2 dp — the width symptom', () {
      expect(formatTxAmount('123456789.123456789123456789'), '123,456,789.12');
    });

    test('>= 1000 always shows exactly 2 dp, grouped', () {
      expect(formatTxAmount('1200'), '1,200.00');
      expect(formatTxAmount('1000'), '1,000.00');
      expect(formatTxAmount('999999.999'), '1,000,000.00');
    });

    test('< 1000 keeps up to 6 dp and a minimum of 2', () {
      expect(formatTxAmount('0.75'), '0.75');
      expect(formatTxAmount('0.0042'), '0.0042');
      expect(formatTxAmount('3.5'), '3.50');
      expect(formatTxAmount('999.999999'), '999.999999');
    });

    test('zero is 0.00', () {
      expect(formatTxAmount('0'), '0.00');
      expect(formatTxAmount('0.0'), '0.00');
    });

    test('dust below the 6 dp floor says so instead of rendering zeros', () {
      expect(formatTxAmount('0.0000001'), '<0.000001');
      expect(formatTxAmount('0.000000000001'), '<0.000001');
      // The boundary itself is representable, so it renders.
      expect(formatTxAmount('0.000001'), '0.000001');
    });

    test('returns the magnitude — the caller composes the sign', () {
      expect(formatTxAmount('-0.75'), '0.75');
      expect(formatTxAmount('-123456789.12345'), '123,456,789.12');
    });

    test('unparseable / NaN / infinite pass through untouched', () {
      // T-12-02: the layout-starvation guard. A hostile amount must never
      // reach a number formatter that could emit an unbounded string.
      expect(formatTxAmount('not-a-number'), 'not-a-number');
      expect(formatTxAmount(''), '');
      expect(formatTxAmount('  0x1f  '), '0x1f');
      expect(formatTxAmount('NaN'), 'NaN');
      expect(formatTxAmount('Infinity'), 'Infinity');
      expect(formatTxAmount('-Infinity'), '-Infinity');
    });
  });

  group('exactTxAmount', () {
    test('preserves the raw string when the clamp lost precision', () {
      expect(
        exactTxAmount('123456789.123456789123456789'),
        '123456789.123456789123456789',
      );
      expect(exactTxAmount('999999.999'), '999999.999');
    });

    test('is null when nothing was lost, so no tooltip is attached', () {
      expect(exactTxAmount('0.75'), isNull);
      expect(exactTxAmount('0.0042'), isNull);
    });
  });

  group('sanitizeCoinAsset', () {
    test('a traversal-shaped symbol survives only as a-z0-9', () {
      // T-12-01: this string is interpolated into
      // assets/images/crypto/<symbol>.png.
      expect(sanitizeCoinAsset('../../etc/passwd'), 'etcpasswd');
      expect(sanitizeCoinAsset('..%2F..%2Feth'), '2f2feth');
      expect(sanitizeCoinAsset('eth.png'), 'ethpng');
    });

    test('lowercases and caps at 12 characters', () {
      expect(sanitizeCoinAsset('ETH'), 'eth');
      expect(sanitizeCoinAsset('MEGALONGSYMBOLNAME'), 'megalongsymb');
      expect(sanitizeCoinAsset('MEGALONGSYMBOLNAME').length, 12);
    });

    test('an all-punctuation symbol yields empty — the neutral-dot signal', () {
      expect(sanitizeCoinAsset('///'), '');
      expect(sanitizeCoinAsset(''), '');
    });
  });

  group('fiatValue', () {
    const prices = {'eth': 3200.0, 'gnus': 0.85};

    test(
      'an unknown symbol is null, never 0 — absence, not a wrong number',
      () {
        expect(
          fiatValue(symbol: 'NOPE', amount: 5, pricesBySymbol: prices),
          isNull,
        );
        expect(
          fiatValue(symbol: 'ETH', amount: 5, pricesBySymbol: const {}),
          isNull,
        );
      },
    );

    test('multiplies price by amount, case-insensitively', () {
      expect(fiatValue(symbol: 'eth', amount: 2, pricesBySymbol: prices), 6400);
      expect(fiatValue(symbol: 'ETH', amount: 2, pricesBySymbol: prices), 6400);
    });
  });

  group('txRowContent — one anatomy for all seven types', () {
    const prices = {'eth': 3200.0, 'gnus': 0.85};

    /// Every TransactionType value, plus the null type the model allows.
    final typeCases = <TransactionType?>[...TransactionType.values, null];

    test('every type produces a complete row record', () {
      // This loop IS the TX-01 requirement. It fails the moment a future edit
      // reintroduces a bare-string row for one type.
      for (final type in typeCases) {
        for (final direction in TransactionDirection.values) {
          final content = txRowContent(
            makeTx(type: type, direction: direction),
            prices: prices,
          );
          final where = 'type=$type direction=$direction';
          expect(content.title, isNotEmpty, reason: 'title empty for $where');
          expect(content.action, isNotEmpty, reason: 'action empty for $where');
          expect(
            content.subtitle,
            isNotEmpty,
            reason: 'subtitle empty for $where',
          );
          expect(content.amount, isNotEmpty, reason: 'amount empty for $where');
          expect(content.time, isNotEmpty, reason: 'time empty for $where');
          expect(
            content.iconSymbols,
            isNotEmpty,
            reason: 'iconSymbols empty for $where',
          );
        }
      }
    });

    test('badge: status wins over type', () {
      expect(
        txRowContent(
          makeTx(type: TransactionType.mint, status: TransactionStatus.pending),
          prices: prices,
        ).badge,
        TransactionBadgeKind.pending,
      );
      expect(
        txRowContent(
          makeTx(type: TransactionType.mint, status: TransactionStatus.failed),
          prices: prices,
        ).badge,
        TransactionBadgeKind.failed,
      );
      expect(
        txRowContent(
          makeTx(
            type: TransactionType.mint,
            status: TransactionStatus.cancelled,
          ),
          prices: prices,
        ).badge,
        TransactionBadgeKind.failed,
      );
      expect(
        txRowContent(makeTx(type: TransactionType.mint), prices: prices).badge,
        TransactionBadgeKind.mint,
      );
    });

    test('badge: a null type falls back to direction, like transfer', () {
      expect(
        txRowContent(
          makeTx(direction: TransactionDirection.sent),
          prices: prices,
        ).badge,
        TransactionBadgeKind.sent,
      );
      expect(
        txRowContent(
          makeTx(direction: TransactionDirection.received),
          prices: prices,
        ).badge,
        TransactionBadgeKind.received,
      );
    });

    test('failed prints the real amount, quietly, and no currency zero', () {
      final content = txRowContent(
        makeTx(status: TransactionStatus.failed),
        prices: prices,
      );
      // Byte-identical to what this same transaction prints when completed —
      // that identity is the whole point of running the type branch first.
      expect(content.amount, '$minus 0.75 ETH');
      expect(
        content.amount,
        txRowContent(
          makeTx(status: TransactionStatus.completed),
          prices: prices,
        ).amount,
      );
      expect(content.valueLine, 'Not charged');
      // Still `none` — but now for a NEW reason. It is no longer "there is no
      // number here"; it is "this number did not move", and `none` ->
      // textSecondary is what keeps a failed row from scanning like a spend.
      expect(content.tone, TxAmountTone.none);
      // The doubled `$0.00` sketch 010 named must not be reachable.
      expect(content.amount, isNot(contains(r'$')));
      expect(content.valueLine, isNot(contains(r'$')));
      // ...and the status is stated exactly once, in the subtitle.
      expect('Failed'.allMatches(content.subtitle).length, 1);
      expect(content.valueLine, isNot(contains('Failed')));
    });

    test('cancelled behaves like failed', () {
      final content = txRowContent(
        makeTx(status: TransactionStatus.cancelled),
        prices: prices,
      );
      expect(content.amount, '$minus 0.75 ETH');
      expect(content.tone, TxAmountTone.none);
      expect(content.valueLine, 'Not charged');
      expect(content.subtitle, contains('Cancelled'));
    });

    test('a failed receive is never green', () {
      // T-15-01. `incoming` -> statusSuccess is this app's SUCCESS colour; on a
      // transaction that failed it would be an outright false claim. This is
      // the test that reddens if the dead override is ever moved back above the
      // type branches, or if the direction tone is allowed to survive it.
      final content = txRowContent(
        makeTx(
          direction: TransactionDirection.received,
          status: TransactionStatus.failed,
        ),
        prices: prices,
      );
      expect(content.amount, startsWith('+'));
      expect(content.tone, TxAmountTone.none);
      expect(content.tone, isNot(TxAmountTone.incoming));
      expect(content.valueLine, 'Not charged');
    });

    test('a failed job still prints its fee, and still says Not charged', () {
      // The architectural test: a failed job has no transfer amount at all, so
      // any implementation that special-cases dead rows BEFORE the type has
      // nothing to print here and falls back to a dash.
      final content = txRowContent(
        makeTx(
          type: TransactionType.process,
          status: TransactionStatus.failed,
          fees: '0.002',
        ),
        prices: prices,
      );
      expect(content.amount, '$minus 0.002 ETH');
      expect(content.tone, TxAmountTone.none);
      expect(content.valueLine, 'Not charged');
      expect(content.valueLine, isNot(contains(r'$')));
    });

    test('no row anywhere prints a dash where the number belongs', () {
      // TT-06 made permanent. Every type crossed with every status: none of
      // them may fall back to an em dash, and none may print nothing at all.
      for (final type in typeCases) {
        for (final status in TransactionStatus.values) {
          for (final direction in TransactionDirection.values) {
            final content = txRowContent(
              makeTx(type: type, status: status, direction: direction),
              prices: prices,
            );
            final where = 'type=$type status=$status direction=$direction';
            expect(
              content.amount,
              isNot(emDash),
              reason: 'em dash amount for $where',
            );
            expect(
              content.amount,
              isNot(contains(emDash)),
              reason: 'em dash inside the amount for $where',
            );
            expect(content.amount, isNotEmpty, reason: 'empty amount $where');
          }
        }
      }
    });

    test('a processing job prints the fee it spent, at full weight', () {
      // TT-06: the fee IS the job's economic content and it genuinely leaves
      // the wallet, so it belongs in the amount column with a real sign — not
      // demoted to the grey value line behind a dash (12-02's behaviour).
      final content = txRowContent(
        makeTx(type: TransactionType.process, fees: '0.002'),
        prices: prices,
      );
      expect(content.amount, '$minus 0.002 ETH');
      // `outgoing` -> textPrimary: identical ink to a successful send, because
      // that GNUS is just as gone.
      expect(content.tone, TxAmountTone.outgoing);
      // 0.002 * 3200. The word `fee` is what stops it reading as a transfer.
      expect(content.valueLine, r'$6.40 fee');
      // The DRAWER title is unchanged - the header has room for the long form.
      expect(content.action, 'Processing job');
      // `makeTx` defaults to COMPLETED, so this is the row that has the whole
      // 113.0px line and takes the full wording. Exact equality replaces the old
      // `startsWith('Job ')`: the line is now the word and nothing else, so a
      // prefix check would no longer be able to tell a bare lead from a lead
      // that regrew a qualifier.
      expect(content.subtitle, 'Processing job');
      expect(content.subtitleLead, 'Processing job');
      // An EQUALITY where there used to be an inequality, and that identity IS
      // the restoration Jakub asked for on 2026-08-07: the row's lead and the
      // drawer's title are the same string for this type again. The old
      // assertion pinned the opposite - that the row deliberately said something
      // shorter than the drawer - and it was true only while the hash shared
      // this line.
      expect(content.subtitleLead, content.action);
      // The hash left the row entirely, so there is no qualifier at all. The
      // general form of this is the every-type loop below.
      expect(content.subtitleBase, isEmpty);
    });

    // THE HYBRID, ruled by Jakub on 2026-08-07 after being shown the measured
    // table: the full wording where it fits, the short word where it does not.
    //
    // A COMPLETED job row has the whole 113.0px line and `Processing job` is
    // 103.6px. The other three statuses pin a status tail to that line, leaving
    // 68.2px (failed), 53.1px (pending) or 40.7px (cancelled), and the full
    // wording needs 115.9px including its ellipsis - so those rows keep `Job`
    // at 26.1px, which clears even the narrowest of them.
    //
    // The accepted cost is that the label's length varies with status. That is
    // unusual and it is deliberate: on those three rows the status word sits
    // right beside the lead, so `Job` next to `Pending` reads completely while
    // `Proces…` next to `Pending` reads as nothing.
    //
    // `transaction_row_subtitle_test.dart` holds the pixel side of this. What is
    // asserted here is the MAPPING - which word each status gets - so the two
    // halves cannot drift apart.
    test('the job row takes the full wording only where it fits', () {
      for (final status in TransactionStatus.values) {
        final content = txRowContent(
          makeTx(type: TransactionType.process, status: status),
          prices: prices,
        );
        final expected = status == TransactionStatus.completed
            ? 'Processing job'
            : 'Job';
        expect(
          content.subtitleLead,
          expected,
          reason: 'a $status job row should lead with "$expected"',
        );
        // Whichever word it is, it is the WHOLE second line: no qualifier, and
        // above all no hash.
        expect(content.subtitleBase, isEmpty, reason: 'status=$status');
        // The drawer's title does not vary. It has a header to spend, so it says
        // the long form on all four.
        expect(content.action, 'Processing job', reason: 'status=$status');
      }
    });

    // THE REMOVAL, made permanent. `process` was the only arm that printed the
    // transaction's own hash, and this is what stops it coming back anywhere.
    //
    // The fixture makes this a real check rather than a vacuous one: `makeTx`'s
    // hash `0xabcdef1234567890` is 18 characters and is DISTINCT from both
    // `fromAddress` and the recipient's `toAddr`, so its display form
    // `0xabcd...7890` cannot collide with a counterparty that is legitimately on
    // the row. Change any of those three and check this again.
    test('no row prints the transaction hash, at any type or status', () {
      final hashDisplay = WalletUtils.getAddressForDisplay(
        '0xabcdef1234567890',
      );
      expect(hashDisplay, isNotEmpty);
      for (final type in typeCases) {
        for (final direction in TransactionDirection.values) {
          for (final status in TransactionStatus.values) {
            final where = 'type=$type direction=$direction status=$status';
            final content = txRowContent(
              makeTx(type: type, direction: direction, status: status),
              prices: prices,
            );
            expect(
              content.subtitleBase,
              isNot(contains(hashDisplay)),
              reason: 'the hash is back in the qualifier for $where',
            );
            expect(
              content.subtitle,
              isNot(contains(hashDisplay)),
              reason: 'the hash is back in the composed line for $where',
            );
          }
        }
      }
    });

    // The other half of that, and the half that stops a future edit from
    // "finishing the job": exactly ONE type has an empty qualifier for content
    // reasons and one for having no qualifier at all. Every other type still
    // carries its own - a place, a quantity or a counterparty - and none of
    // those is a transaction identifier.
    test('only the job and card rows have an empty qualifier', () {
      for (final type in typeCases) {
        for (final direction in TransactionDirection.values) {
          final content = txRowContent(
            makeTx(type: type, direction: direction),
            prices: prices,
          );
          final where = 'type=$type direction=$direction';
          if (type == TransactionType.process ||
              type == TransactionType.purchase) {
            expect(content.subtitleBase, isEmpty, reason: where);
          } else {
            expect(
              content.subtitleBase,
              isNotEmpty,
              reason:
                  'the qualifier vanished for $where. `to wallet`, `in escrow`, '
                  '`from escrow`, the swap amount and both transfer '
                  'counterparties are NOT transaction identifiers and were '
                  'never in scope for the 2026-08-07 removal',
            );
          }
        }
      }
    });

    test('a job fee keeps its full precision for the tooltip', () {
      final content = txRowContent(
        makeTx(type: TransactionType.process, fees: '0.0020000001'),
        prices: prices,
      );
      expect(content.amount, '$minus 0.002 ETH');
      expect(content.exactAmount, '0.0020000001');
    });

    test('an unpriced job fee drops the value line, never fabricates one', () {
      final content = txRowContent(
        makeTx(
          type: TransactionType.process,
          coinSymbol: 'NOPE',
          fees: '0.002',
        ),
        prices: prices,
      );
      // The amount still states the fee — only the fiat is unknown.
      expect(content.amount, '$minus 0.002 NOPE');
      expect(content.valueLine, isNull);
    });

    test('a swap carries both symbols and both icons', () {
      final content = txRowContent(
        makeTx(type: TransactionType.swap),
        prices: prices,
      );
      expect(content.title, contains('ETH'));
      expect(content.title, contains('GNUS'));
      expect(content.title, contains('→'));
      expect(content.iconSymbols, ['eth', 'gnus']);
      expect(content.iconSymbols.length, 2);
      expect(content.amount, '+ 1,200.50 GNUS');
      expect(content.tone, TxAmountTone.incoming);
      // Fiat of the TO side: 1200.5 * 0.85. The exact decimal is 1020.425, a
      // half-way case — as an IEEE754 double it is 1020.42499…, so it rounds
      // down. Deterministic on every platform; pinned here on purpose.
      expect(content.valueLine, r'$1,020.42');
      // The subtitle states the FROM side. 179-C: it now also states the VERB,
      // which is the one word a swap row never carried. Asserted as three
      // separate facts rather than the old single composed string, so a future
      // edit that moves the word between the pieces still fails here.
      expect(content.subtitleLead, 'Swapped');
      expect(content.subtitleBase, '· 1.50 ETH');
      expect(content.subtitle, 'Swapped · 1.50 ETH');
    });

    test('a completed subtitle carries no status token at all', () {
      // T-12-04: if this regresses, a failed spend renders as a successful one.
      for (final type in typeCases) {
        final subtitle = txRowContent(
          makeTx(type: type, status: TransactionStatus.completed),
          prices: prices,
        ).subtitle;
        for (final word in ['Completed', 'Pending', 'Failed', 'Cancelled']) {
          expect(
            subtitle,
            isNot(contains(word)),
            reason: '"$word" leaked into a completed $type subtitle',
          );
        }
      }
    });

    test('a pending subtitle states pending exactly once', () {
      final subtitle = txRowContent(
        makeTx(status: TransactionStatus.pending),
        prices: prices,
      ).subtitle;
      expect('Pending'.allMatches(subtitle).length, 1);
    });

    test('sign and tone follow the money, using a real minus', () {
      String amountOf(TransactionType? type, TransactionDirection direction) =>
          txRowContent(
            makeTx(type: type, direction: direction),
            prices: prices,
          ).amount;

      expect(
        amountOf(TransactionType.transfer, TransactionDirection.sent),
        startsWith(minus),
      );
      expect(
        amountOf(TransactionType.transfer, TransactionDirection.received),
        startsWith('+'),
      );
      expect(
        amountOf(TransactionType.escrow, TransactionDirection.sent),
        startsWith(minus),
      );
      for (final type in [
        TransactionType.mint,
        TransactionType.escrowRelease,
        TransactionType.purchase,
      ]) {
        expect(
          amountOf(type, TransactionDirection.sent),
          startsWith('+'),
          reason: '$type should read as incoming',
        );
      }
      // U+2212, not a hyphen — tabular alignment depends on it.
      expect(
        amountOf(TransactionType.transfer, TransactionDirection.sent),
        isNot(startsWith('-')),
      );
    });

    test('an unpriced coin drops the value line rather than printing zero', () {
      final content = txRowContent(
        makeTx(type: TransactionType.transfer, coinSymbol: 'NOPE'),
        prices: prices,
      );
      expect(content.valueLine, isNull);

      final priced = txRowContent(
        makeTx(type: TransactionType.transfer, coinSymbol: 'ETH'),
        prices: prices,
      );
      expect(priced.valueLine, r'$2,400.00'); // 0.75 * 3200
    });

    test('the whale amount is clamped in the row and kept for the tooltip', () {
      final content = txRowContent(
        makeTx(
          type: TransactionType.transfer,
          direction: TransactionDirection.received,
          amount: '123456789.123456789123456789',
        ),
        prices: prices,
      );
      expect(content.amount, '+ 123,456,789.12 ETH');
      expect(content.exactAmount, '123456789.123456789123456789');
    });

    test('empty recipients does not throw', () {
      // `recipients.first` is what today's code calls unguarded on a list that
      // comes from an untrusted source.
      for (final type in typeCases) {
        expect(
          () => txRowContent(
            makeTx(type: type, recipients: const []),
            prices: prices,
          ),
          returnsNormally,
          reason: 'threw for type=$type',
        );
      }
      final content = txRowContent(
        makeTx(recipients: const []),
        prices: prices,
      );
      // 179-C: the fallback keeps its own words and gains the verb in front of
      // them. Both pieces are pinned, not just the composed line, so the
      // fallback cannot quietly migrate into the lead where it would stop
      // ellipsising.
      expect(content.subtitleBase, '· Unknown recipient');
      expect(content.subtitleLead, 'Sent');
      expect(content.subtitle, 'Sent · Unknown recipient');
      expect(content.amount, '$minus 0.00 ETH');
    });

    test('a null swap symbol falls back to coinSymbol, never to null text', () {
      final content = txRowContent(
        makeTx(
          type: TransactionType.swap,
          fromSymbol: null,
          toSymbol: null,
          coinSymbol: 'ETH',
        ),
        prices: prices,
      );
      expect(content.title, 'ETH');
      expect(content.amount, isNot(contains('null')));
      expect(content.subtitle, isNot(contains('null')));
      expect(content.iconSymbols, ['eth', 'eth']);
    });

    test('symbols reaching the widget are already sanitised', () {
      final content = txRowContent(
        makeTx(coinSymbol: '../../etc/passwd'),
        prices: prices,
      );
      expect(content.iconSymbols, ['etcpasswd']);
    });

    // ---------------------------------------------------------------------
    // 179-C: the subtitle is three pieces now, and these are what stop them
    // from ever stating three different things about one row.
    // ---------------------------------------------------------------------

    test('the three pieces recompose to the subtitle, for every row', () {
      // THE invariant. `subtitle` is the composed whole line and the row draws
      // the pieces; if this fails, one presentation is lying about a row.
      for (final type in typeCases) {
        for (final direction in TransactionDirection.values) {
          for (final status in TransactionStatus.values) {
            final content = txRowContent(
              makeTx(type: type, direction: direction, status: status),
              prices: prices,
            );
            final where = 'type=$type direction=$direction status=$status';
            final lead = content.subtitleLead ?? '';
            final base = content.subtitleBase;
            var composed = [
              lead,
              base,
            ].where((piece) => piece.isNotEmpty).join(' ');
            final tail = content.statusTail;
            if (tail != null) {
              composed = '$composed · $tail';
            }
            expect(composed, content.subtitle, reason: 'recompose for $where');
          }
        }
      }
    });

    test('the qualifier never repeats the lead', () {
      // The doubling the deleted chip caused - `Minted` in the chip and
      // `Minted to wallet` beneath it - must not be reintroduceable.
      for (final type in typeCases) {
        for (final direction in TransactionDirection.values) {
          final content = txRowContent(
            makeTx(type: type, direction: direction),
            prices: prices,
          );
          expect(
            content.subtitleBase,
            isNot(startsWith(content.subtitleLead!)),
            reason: 'subtitleBase repeats the lead for type=$type',
          );
        }
      }
    });

    test('every type has a non-empty lead', () {
      // The lead is what keeps the second line from collapsing now that the
      // qualifier is allowed to be empty (purchase).
      for (final type in typeCases) {
        for (final direction in TransactionDirection.values) {
          final content = txRowContent(
            makeTx(type: type, direction: direction),
            prices: prices,
          );
          expect(
            content.subtitleLead,
            isNotNull,
            reason: 'null lead for type=$type',
          );
          expect(
            content.subtitleLead,
            isNotEmpty,
            reason: 'empty lead for type=$type',
          );
        }
      }
    });

    test('statusTail is null on the happy path and set on the other three', () {
      // The narrow row draws this and the wide page draws a pill from the same
      // two fields, so this is also what stops the two from disagreeing.
      expect(
        txRowContent(
          makeTx(status: TransactionStatus.completed),
          prices: prices,
        ).statusTail,
        isNull,
      );
      for (final status in [
        TransactionStatus.pending,
        TransactionStatus.failed,
        TransactionStatus.cancelled,
      ]) {
        final content = txRowContent(makeTx(status: status), prices: prices);
        expect(
          content.statusTail,
          status.name[0].toUpperCase() + status.name.substring(1),
          reason: 'statusTail for $status',
        );
        // No leading middle dot: the row pins this as its own element with its
        // own gutter, and the 8px a dot costs is what clips `Minted` at 113px.
        expect(content.statusTail, isNot(contains('·')));
      }
    });

    test('a caller-supplied statusLabel reaches the tail, not the enum name', () {
      // The Buy GNUS orders rail's `Expired` folds onto `failed`. The tail is a
      // GETTER over status + statusLabel precisely so the rail keeps its own
      // word on the narrow row without an edit to `lib/banxa/`.
      const content = TxRowContent(
        badge: TransactionBadgeKind.purchase,
        title: 'GNUS',
        action: 'Purchased',
        subtitle: 'Today · Card purchase · Expired',
        subtitleBase: 'Today · Card purchase',
        status: TransactionStatus.failed,
        amount: '+ 100.00 GNUS',
        tone: TxAmountTone.incoming,
        exactAmount: null,
        valueLine: null,
        iconSymbols: ['gnus'],
        time: '18:42',
        statusLabel: 'Expired',
      );
      expect(content.statusTail, 'Expired');
      // And a record that opts out of the lead keeps its single-piece line.
      expect(content.subtitleLead, isNull);
    });
  });

  group('txTimeLabel', () {
    test('is fixed-width 24-hour, zero padded', () {
      expect(txTimeLabel(DateTime(2026, 7, 22, 18, 42)), '18:42');
      expect(txTimeLabel(DateTime(2026, 7, 22, 9, 5)), '09:05');
      expect(txTimeLabel(DateTime(2026, 7, 22, 0, 0)), '00:00');
      // No locale meridiem — that variable width is what it exists to avoid.
      expect(txTimeLabel(DateTime(2026, 7, 22, 13, 0)), '13:00');
    });
  });

  group('txDayLabel', () {
    final now = DateTime(2026, 7, 22, 12, 0);

    test('today, yesterday, then a real date', () {
      expect(txDayLabel(DateTime(2026, 7, 22, 23, 59), now), 'Today');
      expect(txDayLabel(DateTime(2026, 7, 22, 0, 0), now), 'Today');
      expect(txDayLabel(DateTime(2026, 7, 21, 1, 0), now), 'Yesterday');
      expect(txDayLabel(DateTime(2026, 7, 18), now), '18 Jul');
    });

    test('a different year keeps the year', () {
      expect(txDayLabel(DateTime(2025, 7, 18), now), '18 Jul 2025');
    });

    test('the comparison is calendar-based, not a duration', () {
      // 23 hours apart but two different calendar days: a Duration-based
      // implementation would call the earlier one "Today".
      final late = DateTime(2026, 7, 21, 23, 30);
      final later = DateTime(2026, 7, 22, 22, 30);
      expect(later.difference(late), const Duration(hours: 23));
      expect(txDayLabel(late, now), 'Yesterday');
      expect(txDayLabel(later, now), 'Today');
    });

    test('month and year rollover', () {
      expect(
        txDayLabel(DateTime(2026, 6, 30), DateTime(2026, 7, 1, 9)),
        'Yesterday',
      );
      expect(
        txDayLabel(DateTime(2025, 12, 31), DateTime(2026, 1, 1, 9)),
        'Yesterday',
      );
    });
  });

  group('groupTransactionsByDay', () {
    final now = DateTime(2026, 7, 22, 20, 0);

    List<Transaction> threeDays() => [
      makeTx(hash: 'y-early', timeStamp: DateTime(2026, 7, 21, 8, 0)),
      makeTx(hash: 't-late', timeStamp: DateTime(2026, 7, 22, 18, 0)),
      makeTx(hash: 'old', timeStamp: DateTime(2026, 7, 18, 10, 0)),
      makeTx(hash: 't-early', timeStamp: DateTime(2026, 7, 22, 9, 0)),
      makeTx(hash: 'y-late', timeStamp: DateTime(2026, 7, 21, 22, 0)),
    ];

    test('buckets into labelled calendar days, newest first', () {
      final days = groupTransactionsByDay(threeDays(), now: now);
      expect(days.map((d) => d.label), ['Today', 'Yesterday', '18 Jul']);
      expect(days.map((d) => d.items.length), [2, 2, 1]);
    });

    test('items inside a day are newest first too', () {
      final days = groupTransactionsByDay(threeDays(), now: now);
      expect(days[0].items.map((t) => t.hash), ['t-late', 't-early']);
      expect(days[1].items.map((t) => t.hash), ['y-late', 'y-early']);
    });

    test('does not mutate the caller\'s list', () {
      // The source is bloc/stream-owned; reordering it under the caller would
      // be a real bug, not a cosmetic one.
      final source = threeDays();
      final before = source.map((t) => t.hash).toList();
      groupTransactionsByDay(source, now: now);
      expect(source.map((t) => t.hash).toList(), before);
    });

    test('empty in, empty out', () {
      expect(groupTransactionsByDay(const [], now: now), isEmpty);
    });

    test('two transactions 23 hours apart still split into two days', () {
      final txs = [
        makeTx(hash: 'a', timeStamp: DateTime(2026, 7, 21, 23, 30)),
        makeTx(hash: 'b', timeStamp: DateTime(2026, 7, 22, 22, 30)),
      ];
      final days = groupTransactionsByDay(txs, now: DateTime(2026, 7, 22, 23));
      expect(days.length, 2);
      expect(days.map((d) => d.label), ['Today', 'Yesterday']);
    });

    test('the day key is the local midnight of its bucket', () {
      final days = groupTransactionsByDay(threeDays(), now: now);
      expect(days.first.day, DateTime(2026, 7, 22));
    });
  });
}
