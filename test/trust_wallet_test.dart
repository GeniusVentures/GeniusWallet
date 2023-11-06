
import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:test/test.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';

void main() {

  group('Trust Wallet FFI', () {
    
    test('Trust Wallet Creation', () {
      final tWallet = FFIBridgePrebuilt();
      expect(tWallet.wallet_lib.stringForHRP(TWHRP.TWHRPStride).cast<Utf8>().toDartString(), 'stride');

    });
  });
}