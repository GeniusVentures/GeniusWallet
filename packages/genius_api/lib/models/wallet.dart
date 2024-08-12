import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genius_api/models/transaction.dart';
part 'wallet.freezed.dart';
part 'wallet.g.dart';

@freezed
class Wallet with _$Wallet {
  const factory Wallet({
    required int coinType,
    required String walletName,
    required String currencySymbol,

    /// The idea for making balance an int is that we store the smallest unit (i.e. satoshis, wei, etc.). However, these can be changed
    required int balance,
    required String address,
    required List<Transaction> transactions,
  }) = _Wallet;

  factory Wallet.fromJson(Map<String, Object?> json) => _$WalletFromJson(json);
}
