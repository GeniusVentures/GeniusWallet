import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:test/test.dart';
import 'dart:io';
void main() {

    test('Trust Wallet Creation', () {
      final tWallet = FFIBridgePrebuilt();
      expect(tWallet.getValueFromNative(),  12.0);
    });
}