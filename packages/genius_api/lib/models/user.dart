import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genius_api/models/wallet.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String profilePictureUrl,
    required String nickname,
    required String email,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required List<Wallet> wallets,
  }) = _User;

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);
}
