import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 4)
enum TransactionDirection {
  @HiveField(0)
  sent,
  @HiveField(1)
  received,
}

@HiveType(typeId: 5)
enum TransactionStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  cancelled,
  @HiveField(2)
  completed,
  @HiveField(3)
  failed
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
  purchase;

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

  TransferRecipients({
    required this.toAddr,
    required this.amount,
  });
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
  });
}
