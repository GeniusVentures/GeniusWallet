import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String hash,
    required String fromAddress,
    required String toAddress,
    required String timeStamp,
    required TransactionDirection transactionDirection,
    required String amount,
    required String fees,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, Object?> json) =>
      _$TransactionFromJson(json);
}

enum TransactionDirection { sent, received }
