import 'dart:ffi';
import 'dart:typed_data';

import 'package:genius_api/extensions/extensions.dart';
import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/tw/mnemonic_impl.dart';
import 'package:genius_api/tw/string_util.dart';

class HDWalletImpl {
  static FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();

  static Pointer<Void> create({int strength = 128, String passphrase = ""}) {
    assert(strength >= 128 && strength <= 256 && strength % 32 == 0);
    final passphraseTWString = StringUtil.toTWString(passphrase);
    final wallet = ffiBridgePrebuilt.wallet_lib
        .TWHDWalletCreate(strength, passphraseTWString.cast());
    StringUtil.delete(passphraseTWString);
    return wallet.cast();
  }

  static Pointer<Void> createWithMnemonic(String mnemonic,
      {String passphrase = ""}) {
    if (!MnemonicImpl.isValid(mnemonic)) {
      throw Exception(["mnemonic is invalid"]);
    }
    final passphraseTWString = StringUtil.toTWString(passphrase);
    final mnemonicTWString = StringUtil.toTWString(mnemonic);
    final wallet = ffiBridgePrebuilt.wallet_lib.TWHDWalletCreateWithMnemonic(
        mnemonicTWString.cast(), passphraseTWString.cast());
    StringUtil.delete(passphraseTWString);
    StringUtil.delete(mnemonicTWString);
    return wallet.cast();
  }

  static Pointer<Void> createWithEntropy(Uint8List bytes,
      {String passphrase = ""}) {
    final data = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(bytes.toPointerUint8(), bytes.length);
    final passphraseTWString = StringUtil.toTWString(passphrase);
    final wallet = ffiBridgePrebuilt.wallet_lib
        .TWHDWalletCreateWithEntropy(data, passphraseTWString.cast());
    StringUtil.delete(passphraseTWString);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(data);
    return wallet.cast();
  }

  // TODO: CREATE WITH PRIVATE KEY
  // static Pointer<Void> createWithPrivateKey(String privateKey,
  //     {String passphrase = ""}) {
  //   final data = ffiBridgePrebuilt.wallet_lib
  //       .TWDataCreateWithBytes(bytes.toPointerUint8(), bytes.length);
  //   final passphraseTWString = StringUtil.toTWString(passphrase);
  //   final wallet = ffiBridgePrebuilt.wallet_lib
  //       .TWHDWalletCreateWithEntropy(data, passphraseTWString.cast());
  //   StringUtil.delete(passphraseTWString);
  //   ffiBridgePrebuilt.wallet_lib.TWDataDelete(data);
  //   return wallet.cast();
  // }

  static String getAddressForCoin(Pointer<Void> wallet, int coinType) {
    final address = ffiBridgePrebuilt.wallet_lib
        .TWHDWalletGetAddressForCoin(wallet.cast(), coinType);

    return StringUtil.toDartString(address.cast());
  }

  static Pointer<Void> getDerivedKey(
      Pointer<Void> wallet, int coin, int account, int change, int address) {
    final privateKey = ffiBridgePrebuilt.wallet_lib
        .TWHDWalletGetDerivedKey(wallet.cast(), coin, account, change, address);

    return privateKey.cast();
  }

  static Pointer<Void> getMasterKey(Pointer<Void> wallet, int curve) {
    final privateKey = ffiBridgePrebuilt.wallet_lib
        .TWHDWalletGetMasterKey(wallet.cast(), curve);

    return privateKey.cast();
  }

  static void delete(Pointer<Void> wallet) {
    ffiBridgePrebuilt.wallet_lib.TWHDWalletDelete(wallet.cast());
  }

  static Pointer<Void> getKeyForCoin(Pointer<Void> wallet, int coin) {
    final Pointer<Void> privateKey = ffiBridgePrebuilt.wallet_lib
        .TWHDWalletGetKeyForCoin(wallet.cast(), coin)
        .cast();
    return privateKey;
  }

  static Pointer<Void> getKey(
      Pointer<Void> wallet, int coin, String derivationPath) {
    final twDerivationPath = StringUtil.toTWString(derivationPath);

    final Pointer<Void> privateKey = ffiBridgePrebuilt.wallet_lib
        .TWHDWalletGetKey(wallet.cast(), coin, twDerivationPath.cast())
        .cast();
    StringUtil.delete(twDerivationPath);
    return privateKey;
  }

  static Uint8List seed(Pointer<Void> wallet) {
    final data = ffiBridgePrebuilt.wallet_lib.TWHDWalletSeed(wallet.cast());
    return ffiBridgePrebuilt.wallet_lib
        .TWDataBytes(data)
        .asTypedList(ffiBridgePrebuilt.wallet_lib.TWDataSize(data));
  }

  static String mnemonic(Pointer<Void> wallet) {
    return StringUtil.toDartString(
        ffiBridgePrebuilt.wallet_lib.TWHDWalletMnemonic(wallet.cast()).cast());
  }

  static String getExtendedPublicKey(
      Pointer<Void> wallet, int purpose, int coinType, int twHdVersion) {
    final publicKey = ffiBridgePrebuilt.wallet_lib
        .TWHDWalletGetExtendedPublicKey(
            wallet.cast(), purpose, coinType, twHdVersion);

    return StringUtil.toDartString(publicKey.cast());
  }
}
