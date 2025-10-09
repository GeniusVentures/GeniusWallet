import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';
part 'account.g.dart';

@unfreezed
sealed class Account with _$Account {
  factory Account(
      {String? name,
      double? balance,
      DateTime? lastBalanceRetrievalDate}) = _Account;

  factory Account.fromJson(Map<String, Object?> json) =>
      _$AccountFromJson(json);
}
