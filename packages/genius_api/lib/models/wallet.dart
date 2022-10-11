import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genius_api/models/transaction.dart';
part 'wallet.freezed.dart';
part 'wallet.g.dart';

@freezed
class Wallet with _$Wallet {
  const factory Wallet({
    required String walletName,
    required String currencySymbol,
    required String currencyName,
    required int balance,
    required String address,
    required List<Transaction> transactions,
  }) = _Wallet;

  factory Wallet.fromJson(Map<String, Object?> json) => _$WalletFromJson(json);
}
