import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_badge.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';

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
      expect(
        formatTxAmount('123456789.123456789123456789'),
        '123,456,789.12',
      );
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

    test('an unknown symbol is null, never 0 — absence, not a wrong number', () {
      expect(
        fiatValue(symbol: 'NOPE', amount: 5, pricesBySymbol: prices),
        isNull,
      );
      expect(
        fiatValue(symbol: 'ETH', amount: 5, pricesBySymbol: const {}),
        isNull,
      );
    });

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
      expect(content.action, 'Processing job');
      // Derived from the hash — the model carries no job id.
      expect(content.subtitle, startsWith('Job '));
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
      // The subtitle states the FROM side.
      expect(content.subtitle, '1.50 ETH');
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
      expect(amountOf(TransactionType.escrow, TransactionDirection.sent),
          startsWith(minus));
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
      expect(content.subtitle, 'Unknown recipient');
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
