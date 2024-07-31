import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:test/test.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';

void main() {
  group('Trust Wallet FFI', () {
    test('Trust Wallet Link', () {
      final tWallet = FFIBridgePrebuilt();
      expect(
          tWallet.wallet_lib
              .stringForHRP(TWHRP.TWHRPStride)
              .cast<Utf8>()
              .toDartString(),
          'stride');
    });
    test('Trust Wallet Creation with Strength', () {
      final tWallet = FFIBridgePrebuilt();
      Pointer<TWHDWallet>? newWallet;
      Pointer<Utf8> passPhraseCharPtr = "passphrase_1".toNativeUtf8();
      Pointer<Utf8>? stdString = tWallet.wallet_lib
          .TWStringCreateWithUTF8Bytes(passPhraseCharPtr) as Pointer<Utf8>;
      calloc.free(passPhraseCharPtr);
      expect(stdString, isNotNull);
      newWallet = tWallet.wallet_lib.TWHDWalletCreate(128, stdString.cast());
      expect(newWallet, isNotNull);
      tWallet.wallet_lib.TWHDWalletDelete(newWallet);
    });
    test('Trust Wallet Import', () {
      final tWallet = FFIBridgePrebuilt();
      Pointer<TWHDWallet>? newWallet;
      Pointer<Utf8> passPhraseCharPtr = "passphrase_1".toNativeUtf8();
      Pointer<Void>? stdString = tWallet.wallet_lib
          .TWStringCreateWithUTF8Bytes("passphrase_1".toNativeUtf8());
      Pointer<Void>? walletRandomMnemonic;
      calloc.free(passPhraseCharPtr);
      expect(stdString, isNotNull);
      newWallet = tWallet.wallet_lib.TWHDWalletCreate(128, stdString);
      expect(newWallet, isNotNull);
      walletRandomMnemonic = tWallet.wallet_lib.TWHDWalletMnemonic(newWallet);
      Pointer<TWHDWallet>? importWallet;
      importWallet = tWallet.wallet_lib
          .TWHDWalletCreateWithMnemonic(walletRandomMnemonic, stdString);
      Pointer<Char>? addressString = tWallet.wallet_lib
          .TWStringUTF8Bytes(tWallet.wallet_lib.TWHDWalletGetAddressForCoin(
              newWallet, TWCoinType.TWCoinTypeEthereum))
          .cast();
      Pointer<Char>? addressStringImported = tWallet.wallet_lib
          .TWStringUTF8Bytes(tWallet.wallet_lib.TWHDWalletGetAddressForCoin(
              importWallet, TWCoinType.TWCoinTypeEthereum))
          .cast();
      expect(addressString.cast<Utf8>().toDartString(),
          addressStringImported.cast<Utf8>().toDartString());
      tWallet.wallet_lib.TWHDWalletDelete(importWallet);
      tWallet.wallet_lib.TWHDWalletDelete(newWallet);
    });
  });
}
