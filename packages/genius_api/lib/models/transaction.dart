import 'package:hive_ce/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 4)
enum TransactionDirection {
  @HiveField(0)
  sent,
  @HiveField(1)
  received,
}

/// Indices 0-3 are stored on disk and must never be renumbered. New states are
/// appended, so a transaction written by an older build still deserializes.
@HiveType(typeId: 5)
enum TransactionStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  cancelled,
  @HiveField(2)
  completed,
  @HiveField(3)
  failed,

  /// Execution paused mid-route for want of gas on the destination chain. The
  /// funds are held, not lost, and adding gas resumes them.
  @HiveField(4)
  needsGas,

  /// The route's last step reverted, so a different token arrived than was
  /// asked for. Nothing is lost; it is the wrong asset.
  @HiveField(5)
  partialSuccess,

  /// The route could not complete and the funds were returned to the sender.
  @HiveField(6)
  refunded,
}

@HiveType(typeId: 6)
enum TransactionType {
  @HiveField(0)
  transfer,
  @HiveField(1)
  mint,
  @HiveField(2)
  escrow,
  @HiveField(3)
  process,
  @HiveField(4)
  escrowRelease,
  @HiveField(5)
  purchase,
  @HiveField(6)
  swap;

  static TransactionType fromString(String value) {
    if (value == 'escrow-release') {
      return TransactionType.escrowRelease;
    }

    return TransactionType.values.firstWhere(
      (e) => e.toString() == value,
      orElse: () => throw ArgumentError('Invalid transaction: $value'),
    );
  }

  @override
  String toString() {
    if (this == TransactionType.escrowRelease) {
      return 'escrow-release';
    }

    return name;
  }

  String toCapitalizedString() {
    if (this == TransactionType.escrowRelease) {
      return 'Escrow-Release';
    }

    return name[0].toUpperCase() + name.substring(1);
  }
}

@HiveType(typeId: 7)
class TransferRecipients {
  @HiveField(0)
  final String toAddr;

  @HiveField(1)
  final String amount;

  TransferRecipients({required this.toAddr, required this.amount});
}

@HiveType(typeId: 8)
class Transaction {
  @HiveField(0)
  final String hash;

  @HiveField(1)
  final String fromAddress;

  @HiveField(2)
  final List<TransferRecipients> recipients;

  @HiveField(3)
  final DateTime timeStamp;

  @HiveField(4)
  final TransactionDirection transactionDirection;

  @HiveField(5)
  final String fees;

  @HiveField(6)
  final String coinSymbol;

  @HiveField(7)
  final TransactionStatus transactionStatus;

  @HiveField(8)
  final bool? isSGNUS;

  @HiveField(9)
  final TransactionType? type;

  // New fields for swap transactions
  @HiveField(10)
  final String? fromIconUrl;

  @HiveField(11)
  final String? fromAmount;

  @HiveField(12)
  final String? toIconUrl;

  @HiveField(13)
  final String? toAmount;

  @HiveField(14)
  final String? exchangeRate;

  @HiveField(15)
  final String? fromSymbol;

  @HiveField(16)
  final String? toSymbol;

  /// The aggregator's own page for a transfer that stalled, as the API sent
  /// it. Appended at 17 so a row written by an older build still reads; null
  /// there, which is the same as "no action offered".
  @HiveField(17)
  final String? recoveryUrl;

  /// What actually moved, when it differs from [coinSymbol] — the chain's gas
  /// coin. Null on every row an older build wrote and on a native send, where
  /// the two are the same thing.
  @HiveField(18)
  final String? assetSymbol;

  /// The chain this transaction is on, keyed for the explorer link. Null on a
  /// row an older build wrote; [coinSymbol] alone cannot stand in for it
  /// because more than one chain pays gas in the same coin.
  @HiveField(19)
  final int? chainId;

  Transaction({
    required this.hash,
    required this.fromAddress,
    required this.recipients,
    required this.timeStamp,
    required this.transactionDirection,
    required this.fees,
    required this.coinSymbol,
    required this.transactionStatus,
    this.isSGNUS,
    this.type,
    this.fromIconUrl,
    this.fromAmount,
    this.toIconUrl,
    this.toAmount,
    this.exchangeRate,
    this.fromSymbol,
    this.toSymbol,
    this.recoveryUrl,
    this.assetSymbol,
    this.chainId,
  });

  /// The unit a token-aware row should title/amount/icon itself with — the
  /// asset that moved, falling back to the chain's gas coin for a native
  /// send or a row written before this field existed.
  String get assetUnit => assetSymbol ?? coinSymbol;
}
