import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genius_api/types/wallet_type.dart';
part 'wallet.freezed.dart';
part 'wallet.g.dart';

@freezed
class Wallet with _$Wallet {
  const factory Wallet({
    required int coinType,
    required String walletName,
    required String currencySymbol,
    required WalletType walletType,

    /// The idea for making balance an int is that we store the smallest unit (i.e. satoshis, wei, etc.). However, these can be changed
    required double balance,
    required String address,
  }) = _Wallet;

  factory Wallet.fromJson(Map<String, Object?> json) => _$WalletFromJson(json);
}
