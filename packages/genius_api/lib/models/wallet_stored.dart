import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_stored.freezed.dart';
part 'wallet_stored.g.dart';

@freezed
class WalletStored with _$WalletStored {
  const factory WalletStored(
      {required String walletName,
      required String currencySymbol,
      required String mnemonic,
      required String address,
      required int coinType}) = _WalletStored;

  factory WalletStored.fromJson(Map<String, Object?> json) =>
      _$WalletStoredFromJson(json);
}
