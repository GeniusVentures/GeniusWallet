import 'dart:ffi';
import 'dart:typed_data';

import 'package:genius_api/extensions/extensions.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/tw/string_util.dart';

class StoredKeyImpl {
  static FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();
  static Pointer<Void>? importPrivateKey(
      Uint8List pk, String name, Uint8List password, TWCoinType coin) {
    final twName = StringUtil.toTWString(name);
    final twPassword = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(password.toPointerUint8(), password.length);
    final twPk = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(pk.toPointerUint8(), pk.length);
    final twStoredKey = ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyImportPrivateKey(twPk, twName.cast(), twPassword, coin);
    StringUtil.delete(twName);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(twPassword);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(twPk);
    if (twStoredKey.address == 0) {
      return null;
    }
    return twStoredKey.cast();
  }

  static Pointer<Void>? importHDWallet(
      String mnemonic, String name, Uint8List password, TWCoinType coin) {
    final twMnemonic = StringUtil.toTWString(mnemonic);
    final twName = StringUtil.toTWString(name);
    final twPassword = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(password.toPointerUint8(), password.length);

    final twStoredKey = ffiBridgePrebuilt.wallet_lib.TWStoredKeyImportHDWallet(
        twMnemonic.cast(), twName.cast(), twPassword, coin);
    StringUtil.delete(twMnemonic);
    StringUtil.delete(twName);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(twPassword);
    if (twStoredKey.address == 0) {
      return null;
    }
    return twStoredKey.cast();
  }

  static Pointer<Void>? importJson(Uint8List json) {
    final twjson = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(json.toPointerUint8(), json.length);
    final twStoredKey =
        ffiBridgePrebuilt.wallet_lib.TWStoredKeyImportJSON(twjson);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(twjson);
    if (twStoredKey.address == 0) {
      return null;
    }
    return twStoredKey.cast();
  }

  static Uint8List? decryptPrivateKey(
      Pointer<Void> storedKey, Uint8List password) {
    final twPassword = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(password.toPointerUint8(), password.length);
    final twpivateKey = ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyDecryptPrivateKey(storedKey.cast(), twPassword);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(twPassword);
    if (twpivateKey.address == 0) {
      return null;
    }
    return ffiBridgePrebuilt.wallet_lib
        .TWDataBytes(twpivateKey)
        .asTypedList(ffiBridgePrebuilt.wallet_lib.TWDataSize(twpivateKey));
  }

  static String? decryptMnemonic(Pointer<Void> storedKey, Uint8List password) {
    final twPassword = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(password.toPointerUint8(), password.length);

    final twMnemonic = ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyDecryptMnemonic(storedKey.cast(), twPassword);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(twPassword);
    if (twMnemonic.address == 0) {
      return null;
    }
    return StringUtil.toDartString(twMnemonic.cast());
  }

  static Pointer<Void> privateKey(
      Pointer<Void> storedKey, TWCoinType coinType, Uint8List password) {
    final twPassword = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(password.toPointerUint8(), password.length);
    final twprivateKey = ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyPrivateKey(storedKey.cast(), coinType, twPassword);

    ffiBridgePrebuilt.wallet_lib.TWDataDelete(twPassword);
    return twprivateKey.cast();
  }

  static Pointer<Void> wallet(Pointer<Void> storedKey, Uint8List password) {
    final twPassword = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(password.toPointerUint8(), password.length);
    final twwallet = ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyWallet(storedKey.cast(), twPassword);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(twPassword);
    return twwallet.cast();
  }

  static Pointer<Void>? exportJSON(Pointer<Void> storedKey) {
    return ffiBridgePrebuilt.wallet_lib.TWStoredKeyExportJSON(storedKey.cast());
  }

  static Pointer<Void>? load(String path) {
    final twPath = StringUtil.toTWString(path);
    final twLoad = ffiBridgePrebuilt.wallet_lib.TWStoredKeyLoad(twPath.cast());
    StringUtil.delete(twPath);
    if (twLoad.address == 0) {
      return null;
    }
    return twLoad.cast();
  }

  static String identifier(Pointer<Void> storedKey) {
    final twIdentifier =
        ffiBridgePrebuilt.wallet_lib.TWStoredKeyIdentifier(storedKey.cast());
    return StringUtil.toDartString(twIdentifier.cast());
  }

  static String name(Pointer<Void> storedKey) {
    final twName =
        ffiBridgePrebuilt.wallet_lib.TWStoredKeyName(storedKey.cast());
    return StringUtil.toDartString(twName.cast());
  }

  static bool isMnemonic(Pointer<Void> storedKey) {
    return ffiBridgePrebuilt.wallet_lib.TWStoredKeyIsMnemonic(storedKey.cast());
  }

  static void delete(Pointer<Void> storedKey) {
    ffiBridgePrebuilt.wallet_lib.TWStoredKeyDelete(storedKey.cast());
  }

  // Account
  static Pointer<Void> account(Pointer<Void> storedKey, int index) {
    return ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyAccount(storedKey.cast(), index)
        .cast();
  }

  // Account
  static Pointer<Void> accountForCoin(
      Pointer<Void> storedKey, TWCoinType coin, Pointer<Void> wallet) {
    return ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyAccountForCoin(storedKey.cast(), coin, wallet.cast())
        .cast();
  }

  static int accountCount(Pointer<Void> storedKey) {
    return ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyAccountCount(storedKey.cast());
  }

  static void removeAccountForCoin(Pointer<Void> storedKey, TWCoinType coin) {
    ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyRemoveAccountForCoin(storedKey.cast(), coin);
  }

  static void addAccount(
      Pointer<Void> storedKey,
      String address,
      TWCoinType coin,
      String derivationPath, String publicKey, String extendedPublicKey) {
    final twAddress = StringUtil.toTWString(address);
    final twDerivationPath = StringUtil.toTWString(derivationPath);
    final twExtendedPublicKey = StringUtil.toTWString(extendedPublicKey);
    final twPublicKey = StringUtil.toTWString(publicKey);
    ffiBridgePrebuilt.wallet_lib.TWStoredKeyAddAccount(
        storedKey.cast(),
        twAddress.cast(),
        coin,
        twDerivationPath.cast(),
        twPublicKey.cast(),
        twExtendedPublicKey.cast());

    StringUtil.delete(twAddress);
    StringUtil.delete(twDerivationPath);
    StringUtil.delete(twPublicKey);
    StringUtil.delete(twExtendedPublicKey);
  }

  static bool store(Pointer<Void> storedKey, String path) {
    final twPath = StringUtil.toTWString(path);
    final twIsStore = ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyStore(storedKey.cast(), twPath.cast());
    StringUtil.delete(twPath);
    return twIsStore;
  }

  static bool fixAddresses(Pointer<Void> storedKey, Uint8List password) {
    final twPassword = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(password.toPointerUint8(), password.length);
    final twIsOk = ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyFixAddresses(storedKey.cast(), twPassword);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(twPassword);
    return twIsOk;
  }
}
