import 'package:freezed_annotation/freezed_annotation.dart';
part 'wallet.freezed.dart';
part 'wallet.g.dart';

@freezed
class Wallet with _$Wallet {
  const factory Wallet() = _Wallet;

  factory Wallet.fromJson(Map<String, Object?> json) => _$WalletFromJson(json);
}
