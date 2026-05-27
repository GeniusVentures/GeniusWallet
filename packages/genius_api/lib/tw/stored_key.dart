import 'dart:ffi';
import 'dart:typed_data';

import 'package:genius_api/extensions/extensions.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/tw/account.dart';
import 'package:genius_api/tw/hd_wallet.dart';
import 'package:genius_api/tw/private_key.dart';
import 'package:genius_api/tw/string_util.dart';

class StoredKey {
  static final FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();
  late final Pointer<Void> nativehandle;

  StoredKey._(this.nativehandle);

  static StoredKey? importHDWallet(
      String mnemonic, String name, String password, TWCoinType coin) {
    final twMnemonic = StringUtil.toTWString(mnemonic);
    final twName = StringUtil.toTWString(name);
    final twPassword = Uint8List.fromList(password.codeUnits);
    final twPasswordData = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(twPassword.toPointerUint8(), twPassword.length);
    final twStoredKey = ffiBridgePrebuilt.wallet_lib.TWStoredKeyImportHDWallet(
        twMnemonic.cast(), twName.cast(), twPasswordData, coin);
    StringUtil.delete(twMnemonic);
    StringUtil.delete(twName);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(twPasswordData);
    if (twStoredKey.address == 0) {
      return null;
    }
    return StoredKey._(twStoredKey.cast());
  }

  static StoredKey? importPrivateKey(
      Uint8List privateKeyData, String name, String password, TWCoinType coin) {
    final twName = StringUtil.toTWString(name);
    final twPassword = Uint8List.fromList(password.codeUnits);
    final twPasswordData = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(twPassword.toPointerUint8(), twPassword.length);
    final twPk = ffiBridgePrebuilt.wallet_lib.TWDataCreateWithBytes(
        privateKeyData.toPointerUint8(), privateKeyData.length);
    final twStoredKey = ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyImportPrivateKey(twPk, twName.cast(), twPasswordData, coin);
    StringUtil.delete(twName);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(twPasswordData);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(twPk);
    if (twStoredKey.address == 0) {
      return null;
    }
    return StoredKey._(twStoredKey.cast());
  }

  String? exportJson() {
    final data = ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyExportJSON(nativehandle.cast());
    if (data.address == 0) {
      return null;
    }
    final bytes = ffiBridgePrebuilt.wallet_lib
        .TWDataBytes(data)
        .asTypedList(ffiBridgePrebuilt.wallet_lib.TWDataSize(data));
    return String.fromCharCodes(bytes);
  }

  static StoredKey? load(String path) {
    final twPath = StringUtil.toTWString(path);
    final twLoad =
        ffiBridgePrebuilt.wallet_lib.TWStoredKeyLoad(twPath.cast());
    StringUtil.delete(twPath);
    if (twLoad.address == 0) {
      return null;
    }
    return StoredKey._(twLoad.cast());
  }

  static StoredKey? importJson(String json) {
    final codeUnits = Uint8List.fromList(json.codeUnits);
    final twjson = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(codeUnits.toPointerUint8(), codeUnits.length);
    final twStoredKey =
        ffiBridgePrebuilt.wallet_lib.TWStoredKeyImportJSON(twjson);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(twjson);
    if (twStoredKey.address == 0) {
      return null;
    }
    return StoredKey._(twStoredKey.cast());
  }

  String identifier() {
    final twIdentifier = ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyIdentifier(nativehandle.cast());
    return StringUtil.toDartString(twIdentifier.cast());
  }

  String name() {
    final twName =
        ffiBridgePrebuilt.wallet_lib.TWStoredKeyName(nativehandle.cast());
    return StringUtil.toDartString(twName.cast());
  }

  bool isMnemonic() {
    return ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyIsMnemonic(nativehandle.cast());
  }

  int accountCount() {
    return ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyAccountCount(nativehandle.cast());
  }

  void delete() {
    ffiBridgePrebuilt.wallet_lib.TWStoredKeyDelete(nativehandle.cast());
  }

  Account account(int index) {
    return Account(ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyAccount(nativehandle.cast(), index)
        .cast());
  }

  Account accountForCoin(TWCoinType coin, HDWallet hdWallet) {
    return Account(ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyAccountForCoin(
            nativehandle.cast(), coin, hdWallet.getNativeHandle().cast())
        .cast());
  }

  void removeAccountForCoin(TWCoinType coin) {
    ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyRemoveAccountForCoin(nativehandle.cast(), coin);
  }

  void addAccount(String address, TWCoinType coin, String derivationPath,
      String publicKey, String extendedPublicKey) {
    final twAddress = StringUtil.toTWString(address);
    final twDerivationPath = StringUtil.toTWString(derivationPath);
    final twExtendedPublicKey = StringUtil.toTWString(extendedPublicKey);
    final twPublicKey = StringUtil.toTWString(publicKey);
    ffiBridgePrebuilt.wallet_lib.TWStoredKeyAddAccount(
        nativehandle.cast(),
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

  bool store(String path) {
    final twPath = StringUtil.toTWString(path);
    final twIsStore = ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyStore(nativehandle.cast(), twPath.cast());
    StringUtil.delete(twPath);
    return twIsStore;
  }

  Uint8List? decryptPrivateKey(Uint8List password) {
    final twPassword = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(password.toPointerUint8(), password.length);
    final twpivateKey = ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyDecryptPrivateKey(nativehandle.cast(), twPassword);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(twPassword);
    if (twpivateKey.address == 0) {
      return null;
    }
    return ffiBridgePrebuilt.wallet_lib
        .TWDataBytes(twpivateKey)
        .asTypedList(ffiBridgePrebuilt.wallet_lib.TWDataSize(twpivateKey));
  }

  String? decryptMnemonic(Uint8List password) {
    final twPassword = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(password.toPointerUint8(), password.length);
    final twMnemonic = ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyDecryptMnemonic(nativehandle.cast(), twPassword);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(twPassword);
    if (twMnemonic.address == 0) {
      return null;
    }
    return StringUtil.toDartString(twMnemonic.cast());
  }

  PrivateKey? privateKey(TWCoinType coin, Uint8List password) {
    final twPassword = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(password.toPointerUint8(), password.length);
    final twprivateKey = ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyPrivateKey(nativehandle.cast(), coin, twPassword);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(twPassword);
    if (twprivateKey.address == 0) {
      return null;
    }
    return PrivateKey.pointer(twprivateKey.cast());
  }

  HDWallet? wallet(String password) {
    final twPassword = Uint8List.fromList(password.codeUnits);
    final twPasswordData = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(twPassword.toPointerUint8(), twPassword.length);
    final twwallet = ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyWallet(nativehandle.cast(), twPasswordData);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(twPasswordData);
    if (twwallet.address == 0) {
      return null;
    }
    return HDWallet.pointer(twwallet.cast());
  }

  bool fixAddresses(String password) {
    final twPassword = Uint8List.fromList(password.codeUnits);
    final twPasswordData = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(twPassword.toPointerUint8(), twPassword.length);
    final twIsOk = ffiBridgePrebuilt.wallet_lib
        .TWStoredKeyFixAddresses(nativehandle.cast(), twPasswordData);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(twPasswordData);
    return twIsOk;
  }
}
