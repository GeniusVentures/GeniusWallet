import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';

part 'sgnus_connection.freezed.dart';
part 'sgnus_connection.g.dart';

@freezed
sealed class SGNUSConnection with _$SGNUSConnection {
  const factory SGNUSConnection({
    required String sgnusAddress,
    required String walletAddress,
    required GeniusTransactionManagerState? connection,
  }) = _SGNUSConnection;

  factory SGNUSConnection.fromJson(Map<String, Object?> json) =>
      _$SGNUSConnectionFromJson(json);
}
