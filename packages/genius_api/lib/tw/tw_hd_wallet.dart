import 'dart:ffi';
import 'dart:typed_data';

import 'package:genius_api/impl/tw_hd_wallet_impl.dart';
import 'package:genius_api/impl/tw_private_key.dart';

class TWHDWallet {
  late Pointer<Void> _nativehandle;

  TWHDWallet.pointer(Pointer<Void> pointer) {
    _nativehandle = pointer;
  }

  TWHDWallet({int strength = 128, String passphrase = ""}) {
    _nativehandle =
        TWHDWalletImpl.create(strength: strength, passphrase: passphrase);
    if (_nativehandle.hashCode == 0) {
      throw Exception(["HDWallet nativehandle is null"]);
    }
  }

  TWHDWallet.createWithMnemonic(String mnemonic, {String passphrase = ""}) {
    _nativehandle =
        TWHDWalletImpl.createWithMnemonic(mnemonic, passphrase: passphrase);
    if (_nativehandle.hashCode == 0) {
      throw Exception(["HDWallet nativehandle is null"]);
    }
  }

  TWHDWallet.createWithData(Uint8List bytes, {String passphrase = ""}) {
    _nativehandle =
        TWHDWalletImpl.createWithEntropy(bytes, passphrase: passphrase);
    if (_nativehandle.hashCode == 0) {
      throw Exception(["HDWallet nativehandle is null"]);
    }
  }

  String getAddressForCoin(int coinType) {
    return TWHDWalletImpl.getAddressForCoin(_nativehandle, coinType);
  }

  TWPrivateKey getDerivedKey(
      int coinType, int account, int change, int address) {
    final pointer = TWHDWalletImpl.getDerivedKey(
        _nativehandle, coinType, account, change, address);
    return TWPrivateKey.pointer(pointer);
  }

  TWPrivateKey getKeyForCoin(int coinType) {
    final pointer = TWHDWalletImpl.getKeyForCoin(_nativehandle, coinType);
    return TWPrivateKey.pointer(pointer);
  }

  TWPrivateKey getKey(int coinType, String derivationPath) {
    final pointer =
        TWHDWalletImpl.getKey(_nativehandle, coinType, derivationPath);
    return TWPrivateKey.pointer(pointer);
  }

  TWPrivateKey getMaterKey(int curve) {
    final pointer = TWHDWalletImpl.getMasterKey(_nativehandle, curve);
    return TWPrivateKey.pointer(pointer);
  }

  void delete() {
    TWHDWalletImpl.delete(_nativehandle);
  }

  Uint8List seed() {
    return TWHDWalletImpl.seed(_nativehandle);
  }

  String mnemonic() {
    return TWHDWalletImpl.mnemonic(_nativehandle);
  }

  String getExtendedPublicKey(int purpose, int coinType, int twHdVersion) {
    return TWHDWalletImpl.getExtendedPublicKey(
        _nativehandle, purpose, coinType, twHdVersion);
  }
}
