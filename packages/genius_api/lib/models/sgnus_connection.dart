import 'package:freezed_annotation/freezed_annotation.dart';

part 'sgnus_connection.freezed.dart';
part 'sgnus_connection.g.dart';

@freezed
class SGNUSConnection with _$SGNUSConnection {
  const factory SGNUSConnection({
    required String sgnusAddress,
    required String walletAddress,
    required bool isConnected,
  }) = _SGNUSConnection;

  factory SGNUSConnection.fromJson(Map<String, Object?> json) =>
      _$SGNUSConnectionFromJson(json);
}
