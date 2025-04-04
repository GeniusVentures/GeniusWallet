import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

enum TransactionType {
  transfer,
  mint,
  escrow,
  process,
  escrowRelease;

  static TransactionType fromString(String value) {
    // Special case for escrow-release
    if (value == 'escrow-release') {
      return TransactionType.escrowRelease;
    }

    // Handle other cases normally
    return TransactionType.values.firstWhere(
      (e) => e.toString() == value,
      orElse: () => throw ArgumentError('Invalid transaction: $value'),
    );
  }

  @override
  String toString() {
    // Special case for escrowRelease
    if (this == TransactionType.escrowRelease) {
      return 'escrow-release';
    }

    // Default behavior for other enum values
    return name;
  }

  String toCapitalizedString() {
    // Handle escrowRelease special case
    if (this == TransactionType.escrowRelease) {
      return 'Escrow-Release';
    }

    return name[0].toUpperCase() + name.substring(1);
  }
}

@freezed
class TransferRecipients with _$TransferRecipients {
  const factory TransferRecipients({
    required String toAddr,
    required String amount,
  }) = _TransferRecipients;

  factory TransferRecipients.fromJson(Map<String, Object?> json) =>
      _$TransferRecipientsFromJson(json);
}

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String hash,
    required String fromAddress,
    required List<TransferRecipients> recipients,
    required DateTime timeStamp,
    required TransactionDirection transactionDirection,
    required String fees,
    required String coinSymbol,
    required TransactionStatus transactionStatus,
    bool? isSGNUS,
    TransactionType? type,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, Object?> json) =>
      _$TransactionFromJson(json);
}

enum TransactionDirection { sent, received }

enum TransactionStatus { pending, cancelled, completed }
