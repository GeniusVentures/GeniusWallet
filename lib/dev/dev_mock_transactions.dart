import 'package:genius_api/models/transaction.dart';

// DEV-ONLY: fixture provider for the phase-05 transactions walk. Supplies a
// single varied, deterministic batch of transactions (Sent/Received/Escrow/
// Mint/failed/long-value) so the 05-06 transactions view can be visually
// walked on ANY wallet, offline, without live/on-chain state. Never used
// outside kDebugMode && kShowDevTools call sites — see dev_tools_bubble.dart
// for the button that drives this.
class DevMockTransactions {
  DevMockTransactions._();

  static final DevMockTransactions instance = DevMockTransactions._();

  static final DateTime _base = DateTime(2026, 7, 20, 12, 0);

  /// Returns a varied, deterministic set of ~8 transactions exercising every
  /// branch of the transactions view: Sent/Received/Escrow/Mint filters, the
  /// count footer, a failed error-state row, and a long-value amount against
  /// the row overflow guard. [isSgnus] is stamped onto every tx's [isSGNUS].
  List<Transaction> batch({required bool isSgnus}) {
    return [
      // 1. Normal Sent row.
      Transaction(
        hash: '0xdevmock01',
        fromAddress: '0xFromMocked01',
        recipients: [
          TransferRecipients(toAddr: '0xToMocked01', amount: '0.75'),
        ],
        timeStamp: _base.subtract(const Duration(minutes: 1)),
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
        timeStamp: _base.subtract(const Duration(minutes: 2)),
        transactionDirection: TransactionDirection.received,
        fees: '0.001',
        coinSymbol: 'BTC',
        transactionStatus: TransactionStatus.completed,
        isSGNUS: isSgnus,
        type: TransactionType.transfer,
      ),
      // 3. Mint filter.
      Transaction(
        hash: '0xdevmock03',
        fromAddress: '0xFromMocked03',
        recipients: [
          TransferRecipients(toAddr: '0xToMocked03', amount: '1200'),
        ],
        timeStamp: _base.subtract(const Duration(minutes: 3)),
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
        timeStamp: _base.subtract(const Duration(minutes: 4)),
        transactionDirection: TransactionDirection.sent,
        fees: '0.001',
        coinSymbol: 'GNUS',
        transactionStatus: TransactionStatus.pending,
        isSGNUS: isSgnus,
        type: TransactionType.escrow,
      ),
      // 5. Escrow-release ("Completed job"), also matches Escrow filter.
      Transaction(
        hash: '0xdevmock05',
        fromAddress: '0xFromMocked05',
        recipients: [
          TransferRecipients(toAddr: '0xToMocked05', amount: '500'),
        ],
        timeStamp: _base.subtract(const Duration(minutes: 5)),
        transactionDirection: TransactionDirection.received,
        fees: '0.001',
        coinSymbol: 'GNUS',
        transactionStatus: TransactionStatus.completed,
        isSGNUS: isSgnus,
        type: TransactionType.escrowRelease,
      ),
      // 6. Failed error-state row ("Buy - Failed").
      Transaction(
        hash: '0xdevmock06',
        fromAddress: '0xFromMocked06',
        recipients: [
          TransferRecipients(toAddr: '0xToMocked06', amount: '100'),
        ],
        timeStamp: _base.subtract(const Duration(minutes: 6)),
        transactionDirection: TransactionDirection.sent,
        fees: '0.001',
        coinSymbol: 'ETH',
        transactionStatus: TransactionStatus.failed,
        isSGNUS: isSgnus,
        type: TransactionType.purchase,
      ),
      // 7. Swap. Icon URLs left NULL so no NetworkImage fetch fires — keeps
      // the batch fully offline (TransactionSwappedItem guards both).
      Transaction(
        hash: '0xdevmock07',
        fromAddress: '0xFromMocked07',
        recipients: [
          TransferRecipients(toAddr: '0xToMocked07', amount: '1.0'),
        ],
        timeStamp: _base.subtract(const Duration(minutes: 7)),
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
      // 8. Long-value amount, stresses the row overflow guard.
      Transaction(
        hash: '0xdevmock08',
        fromAddress: '0xFromMocked08',
        recipients: [
          TransferRecipients(
            toAddr: '0xToMocked08',
            amount: '123456789.123456789123456789',
          ),
        ],
        timeStamp: _base.subtract(const Duration(minutes: 8)),
        transactionDirection: TransactionDirection.sent,
        fees: '0.001',
        coinSymbol: 'ETH',
        transactionStatus: TransactionStatus.completed,
        isSGNUS: isSgnus,
        type: TransactionType.transfer,
      ),
    ];
  }
}
