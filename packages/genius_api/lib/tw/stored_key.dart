import 'dart:ffi';
import 'dart:typed_data';

import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/tw/account.dart';
import 'package:genius_api/tw/hd_wallet.dart';
import 'package:genius_api/tw/stored_key_impl.dart';
import 'package:genius_api/tw/private_key.dart';

class StoredKey {
  static late Pointer<Void> nativehandle;
  static FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();

  static StoredKey? importHDWallet(
      String mnemonic, String name, String password, TWCoinType coin) {
    final twPassword = Uint8List.fromList(password.codeUnits);
    final pointer =
        StoredKeyImpl.importHDWallet(mnemonic, name, twPassword, coin);
    if (pointer == null) {
      return null;
    }
    nativehandle = pointer;
    return StoredKey();
  }

  static StoredKey? importPrivateKey(
      Uint8List privateKeyData, String name, String password, TWCoinType coin) {
    final twPassword = Uint8List.fromList(password.codeUnits);
    final pointer =
        StoredKeyImpl.importPrivateKey(privateKeyData, name, twPassword, coin);
    if (pointer == null) {
      return null;
    }
    nativehandle = pointer;
    return StoredKey();
  }

  String? exportJson() {
    final data = StoredKeyImpl.exportJSON(nativehandle);
    if (data == null) {
      return null;
    }
    final bytes = ffiBridgePrebuilt.wallet_lib
        .TWDataBytes(data)
        .asTypedList(ffiBridgePrebuilt.wallet_lib.TWDataSize(data));
    return String.fromCharCodes(bytes);
  }

  static StoredKey? load(String path) {
    final pointer = StoredKeyImpl.load(path);
    if (pointer == null) {
      return null;
    }
    nativehandle = pointer;

    return StoredKey();
  }

  static StoredKey? importJson(String json) {
    final codeUnits = Uint8List.fromList(json.codeUnits);
    final pointer = StoredKeyImpl.importJson(codeUnits);
    if (pointer == null) {
      return null;
    }
    nativehandle = pointer;

    return StoredKey();
  }

  String identifier() {
    return StoredKeyImpl.identifier(nativehandle);
  }

  String name() {
    return StoredKeyImpl.name(nativehandle);
  }

  bool isMnemonic() {
    return StoredKeyImpl.isMnemonic(nativehandle);
  }

  int accountCount() {
    return StoredKeyImpl.accountCount(nativehandle);
  }

  void delete() {
    StoredKeyImpl.delete(nativehandle);
  }

  Account account(int index) {
    return Account(StoredKeyImpl.account(nativehandle, index));
  }

  Account accountForCoin(TWCoinType coin, HDWallet hdWallet) {
    return Account(StoredKeyImpl.accountForCoin(
        nativehandle, coin, hdWallet.getNativeHandle()));
  }

  void removeAccountForCoin(TWCoinType coin) {
    StoredKeyImpl.removeAccountForCoin(nativehandle, coin);
  }

  void addAccount(String address, TWCoinType coin, String derivationPath,
      String publicKey, String extendedPublicKey) {
    StoredKeyImpl.addAccount(nativehandle, address, coin, derivationPath,
        publicKey, extendedPublicKey);
  }

  bool store(String path) {
    return StoredKeyImpl.store(nativehandle, path);
  }

  Uint8List? decryptPrivateKey(Uint8List password) {
    Uint8List? data = StoredKeyImpl.decryptPrivateKey(nativehandle, password);
    if (data == null) {
      return null;
    }
    return data;
  }

  String? decryptMnemonic(Uint8List password) {
    return StoredKeyImpl.decryptMnemonic(nativehandle, password);
  }

  PrivateKey? privateKey(TWCoinType coin, Uint8List password) {
    final pointer = StoredKeyImpl.privateKey(nativehandle, coin, password);
    if (pointer.address == 0) {
      return null;
    }
    return PrivateKey.pointer(pointer);
  }

  HDWallet? wallet(String password) {
    final twPassword = Uint8List.fromList(password.codeUnits);
    final pointer = StoredKeyImpl.wallet(nativehandle, twPassword);
    if (pointer.address == 0) {
      return null;
    }
    return HDWallet.pointer(pointer);
  }

  bool fixAddresses(String password) {
    final twPassword = Uint8List.fromList(password.codeUnits);
    return StoredKeyImpl.fixAddresses(nativehandle, twPassword);
  }
}
