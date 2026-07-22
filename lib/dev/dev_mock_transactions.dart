import 'package:genius_api/models/transaction.dart';

// DEV-ONLY: fixture provider for the phase-12 transactions walk. Supplies a
// single varied, deterministic batch of transactions so the transactions view
// can be visually walked on ANY wallet, offline, without live/on-chain state.
// Never used outside kDebugMode && kShowDevTools call sites — see
// dev_tools_bubble.dart for the button that drives this.
class DevMockTransactions {
  DevMockTransactions._();

  static final DevMockTransactions instance = DevMockTransactions._();

  /// Returns a varied, deterministic set of 11 transactions exercising every
  /// branch of the transactions view: all SEVEN `TransactionType` values, all
  /// four `TransactionStatus` values, both directions, a swap with two tokens,
  /// a processing job (whose fee is its only economic content), a long-value
  /// amount against the row clamp, and THREE calendar days so the day
  /// separators (Today / Yesterday / a dated header) all appear.
  /// [isSgnus] is stamped onto every tx's [isSGNUS].
  ///
  /// Timestamps are relative to NOW rather than a frozen instant, because the
  /// day separators are relative: a frozen base would render every row under
  /// one stale date and the Today / Yesterday branches would never be seen.
  /// Content and ordering stay fully deterministic; only the absolute instants
  /// float.
  List<Transaction> batch({required bool isSgnus}) {
    final now = DateTime.now();

    // Wall-clock day arithmetic, not `subtract(Duration(days: n))`: the same
    // reason txDayLabel uses it — a DST day is 23 or 25 hours long, so a
    // Duration can land on the wrong calendar day.
    DateTime daysAgo(int days, int hour, int minute) =>
        DateTime(now.year, now.month, now.day - days, hour, minute);

    // ponytail: the Today bucket is simply `now` minus a few minutes. Ceiling:
    // a batch injected within ~40 minutes of local midnight puts those rows on
    // Yesterday instead, so the walk would see two day groups rather than
    // three. Upgrade path if that ever matters: clamp to local midnight. Not
    // worth the code for a dev button.
    DateTime minutesAgo(int minutes) =>
        now.subtract(Duration(minutes: minutes));

    return [
      // --- Today -----------------------------------------------------------
      // 1. Normal Sent row.
      Transaction(
        hash: '0xdevmock01',
        fromAddress: '0xFromMocked01',
        recipients: [
          TransferRecipients(toAddr: '0xToMocked01', amount: '0.75'),
        ],
        timeStamp: minutesAgo(12),
        transactionDirection: TransactionDirection.sent,
        fees: '0.001',
        coinSymbol: 'ETH',
        transactionStatus: TransactionStatus.completed,
        isSGNUS: isSgnus,
        type: TransactionType.transfer,
      ),
      // 2. Normal Received row.
      Transaction(
        hash: '0xdevmock02',
        fromAddress: '0xFromMocked02',
        recipients: [
          TransferRecipients(toAddr: '0xToMocked02', amount: '0.0042'),
        ],
        timeStamp: minutesAgo(25),
        transactionDirection: TransactionDirection.received,
        fees: '0.001',
        coinSymbol: 'BTC',
        transactionStatus: TransactionStatus.completed,
        isSGNUS: isSgnus,
        type: TransactionType.transfer,
      ),
      // --- Yesterday -------------------------------------------------------
      // 3. Mint filter.
      Transaction(
        hash: '0xdevmock03',
        fromAddress: '0xFromMocked03',
        recipients: [
          TransferRecipients(toAddr: '0xToMocked03', amount: '1200'),
        ],
        timeStamp: daysAgo(1, 9, 15),
        transactionDirection: TransactionDirection.received,
        fees: '0.001',
        coinSymbol: 'GNUS',
        transactionStatus: TransactionStatus.completed,
        isSGNUS: isSgnus,
        type: TransactionType.mint,
      ),
      // 4. Escrow filter, pending status for variety.
      Transaction(
        hash: '0xdevmock04',
        fromAddress: '0xFromMocked04',
        recipients: [
          TransferRecipients(toAddr: '0xToMocked04', amount: '500'),
        ],
        timeStamp: daysAgo(1, 13, 40),
        transactionDirection: TransactionDirection.sent,
        fees: '0.001',
        coinSymbol: 'GNUS',
        transactionStatus: TransactionStatus.pending,
        isSGNUS: isSgnus,
        type: TransactionType.escrow,
      ),
      // 5. Escrow-release, also matches the Escrow filter.
      Transaction(
        hash: '0xdevmock05',
        fromAddress: '0xFromMocked05',
        recipients: [
          TransferRecipients(toAddr: '0xToMocked05', amount: '500'),
        ],
        timeStamp: daysAgo(1, 17, 5),
        transactionDirection: TransactionDirection.received,
        fees: '0.001',
        coinSymbol: 'GNUS',
        transactionStatus: TransactionStatus.completed,
        isSGNUS: isSgnus,
        type: TransactionType.escrowRelease,
      ),
      // 6. FAILED purchase — the error-state row. Its successful sibling is 10.
      Transaction(
        hash: '0xdevmock06',
        fromAddress: '0xFromMocked06',
        recipients: [
          TransferRecipients(toAddr: '0xToMocked06', amount: '100'),
        ],
        timeStamp: daysAgo(1, 21, 30),
        transactionDirection: TransactionDirection.sent,
        fees: '0.001',
        coinSymbol: 'ETH',
        transactionStatus: TransactionStatus.failed,
        isSGNUS: isSgnus,
        type: TransactionType.purchase,
      ),
      // --- Three days back (a dated separator, not Today/Yesterday) ---------
      // 7. Swap. Icon URLs left NULL so no NetworkImage fetch fires — keeps
      // the batch fully offline (the row guards both).
      Transaction(
        hash: '0xdevmock07',
        fromAddress: '0xFromMocked07',
        recipients: [
          TransferRecipients(toAddr: '0xToMocked07', amount: '1.0'),
        ],
        timeStamp: daysAgo(3, 10, 20),
        transactionDirection: TransactionDirection.sent,
        fees: '0.001',
        coinSymbol: 'ETH',
        transactionStatus: TransactionStatus.completed,
        isSGNUS: isSgnus,
        type: TransactionType.swap,
        fromIconUrl: null,
        fromAmount: '1.0',
        toIconUrl: null,
        toAmount: '3200',
        fromSymbol: 'ETH',
        toSymbol: 'USDC',
      ),
      // 8. Long-value amount, stresses the amount clamp. Do not change the
      // value — the walk checks this row explicitly.
      Transaction(
        hash: '0xdevmock08',
        fromAddress: '0xFromMocked08',
        recipients: [
          TransferRecipients(
            toAddr: '0xToMocked08',
            amount: '123456789.123456789123456789',
          ),
        ],
        timeStamp: daysAgo(3, 15, 45),
        transactionDirection: TransactionDirection.sent,
        fees: '0.001',
        coinSymbol: 'ETH',
        transactionStatus: TransactionStatus.completed,
        isSGNUS: isSgnus,
        type: TransactionType.transfer,
      ),
      // 9. PROCESS — the "Completed job" row sketch 010 named as the worst
      // offender, and the only type the old batch could not show at all. Its
      // fee is the row's economic content, so it is deliberately non-trivial.
      Transaction(
        hash: '0xdevmock09',
        fromAddress: '0xFromMocked09',
        recipients: [
          TransferRecipients(toAddr: '0xToMocked09', amount: '25'),
        ],
        timeStamp: minutesAgo(3),
        transactionDirection: TransactionDirection.sent,
        fees: '0.42',
        coinSymbol: 'GNUS',
        transactionStatus: TransactionStatus.completed,
        isSGNUS: isSgnus,
        type: TransactionType.process,
      ),
      // 10. SUCCESSFUL purchase. The old batch had only the failed one, so
      // the success branch of the purchase row had never been seen.
      Transaction(
        hash: '0xdevmock10',
        fromAddress: '0xFromMocked10',
        recipients: [
          TransferRecipients(toAddr: '0xToMocked10', amount: '500'),
        ],
        timeStamp: minutesAgo(40),
        transactionDirection: TransactionDirection.received,
        fees: '0.001',
        coinSymbol: 'GNUS',
        transactionStatus: TransactionStatus.completed,
        isSGNUS: isSgnus,
        type: TransactionType.purchase,
      ),
      // 11. CANCELLED. Makes both the cancelled badge and the rule that the
      // Failed filter spans cancelled walkable.
      Transaction(
        hash: '0xdevmock11',
        fromAddress: '0xFromMocked11',
        recipients: [
          TransferRecipients(toAddr: '0xToMocked11', amount: '3.5'),
        ],
        timeStamp: daysAgo(3, 19, 10),
        transactionDirection: TransactionDirection.sent,
        fees: '0.001',
        coinSymbol: 'ETH',
        transactionStatus: TransactionStatus.cancelled,
        isSGNUS: isSgnus,
        type: TransactionType.transfer,
      ),
    ];
  }
}
