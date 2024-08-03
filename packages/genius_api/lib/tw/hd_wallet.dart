import 'dart:ffi';
import 'dart:typed_data';

import 'package:genius_api/tw/hd_wallet_impl.dart';
import 'package:genius_api/tw/private_key.dart';

class HDWallet {
  late Pointer<Void> nativehandle;

  HDWallet.pointer(Pointer<Void> pointer) {
    nativehandle = pointer;
  }

  HDWallet({int strength = 128, String passphrase = "gnusai"}) {
    nativehandle =
        HDWalletImpl.create(strength: strength, passphrase: passphrase);
    if (nativehandle.hashCode == 0) {
      throw Exception(["HDWallet nativehandle is null"]);
    }
  }

  HDWallet.createWithMnemonic(String mnemonic, {String passphrase = "gnusai"}) {
    nativehandle =
        HDWalletImpl.createWithMnemonic(mnemonic, passphrase: passphrase);
    if (nativehandle.hashCode == 0) {
      throw Exception(["HDWallet nativehandle is null"]);
    }
  }

  HDWallet.createWithData(Uint8List bytes, {String passphrase = "gnusai"}) {
    nativehandle =
        HDWalletImpl.createWithEntropy(bytes, passphrase: passphrase);
    if (nativehandle.hashCode == 0) {
      throw Exception(["HDWallet nativehandle is null"]);
    }
  }

  String getAddressForCoin(int coinType) {
    return HDWalletImpl.getAddressForCoin(nativehandle, coinType);
  }

  PrivateKey getDerivedKey(int coinType, int account, int change, int address) {
    final pointer = HDWalletImpl.getDerivedKey(
        nativehandle, coinType, account, change, address);
    return PrivateKey.pointer(pointer);
  }

  PrivateKey getKeyForCoin(int coinType) {
    final pointer = HDWalletImpl.getKeyForCoin(nativehandle, coinType);
    return PrivateKey.pointer(pointer);
  }

  PrivateKey getKey(int coinType, String derivationPath) {
    final pointer = HDWalletImpl.getKey(nativehandle, coinType, derivationPath);
    return PrivateKey.pointer(pointer);
  }

  PrivateKey getMasterKey(int curve) {
    final pointer = HDWalletImpl.getMasterKey(nativehandle, curve);
    return PrivateKey.pointer(pointer);
  }

  void delete() {
    HDWalletImpl.delete(nativehandle);
  }

  Uint8List seed() {
    return HDWalletImpl.seed(nativehandle);
  }

  String mnemonic() {
    return HDWalletImpl.mnemonic(nativehandle);
  }

  String getExtendedPublicKey(int purpose, int coinType, int twHdVersion) {
    return HDWalletImpl.getExtendedPublicKey(
        nativehandle, purpose, coinType, twHdVersion);
  }

  Pointer<Void> getNativeHandle() {
    return nativehandle;
  }
}
