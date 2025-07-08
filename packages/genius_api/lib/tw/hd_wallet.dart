import 'dart:ffi';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/tw/hd_wallet_impl.dart';
import 'package:genius_api/tw/private_key.dart';
import 'package:genius_api/types/wallet_type.dart';

class HDWallet {
  late Pointer<Void> nativehandle;
  final WalletType walletType = WalletType.mnemonic;
  String? name;

  HDWallet.pointer(Pointer<Void> pointer) {
    nativehandle = pointer;
  }

  HDWallet({int strength = 128, String passphrase = ""}) {
    nativehandle =
        HDWalletImpl.create(strength: strength, passphrase: passphrase);
    if (nativehandle.hashCode == 0) {
      throw Exception(["HDWallet nativehandle is null"]);
    }
  }

  HDWallet.createWithMnemonic(String mnemonic,
      {String passphrase = "", String walletName = ""}) {
    nativehandle =
        HDWalletImpl.createWithMnemonic(mnemonic, passphrase: passphrase);
    name = walletName;
    if (nativehandle.hashCode == 0) {
      throw Exception(["HDWallet nativehandle is null"]);
    }
  }

  HDWallet.createWithData(Uint8List bytes, {String passphrase = ""}) {
    nativehandle =
        HDWalletImpl.createWithEntropy(bytes, passphrase: passphrase);
    if (nativehandle.hashCode == 0) {
      throw Exception(["HDWallet nativehandle is null"]);
    }
  }

  String getAddressForCoin(TWCoinType coinType) {
    return HDWalletImpl.getAddressForCoin(nativehandle, coinType);
  }

  PrivateKey getDerivedKey(
      TWCoinType coinType, int account, int change, int address) {
    final pointer = HDWalletImpl.getDerivedKey(
        nativehandle, coinType, account, change, address);
    return PrivateKey.pointer(pointer);
  }

  PrivateKey getKeyForCoin(TWCoinType coinType) {
    final pointer = HDWalletImpl.getKeyForCoin(nativehandle, coinType);
    return PrivateKey.pointer(pointer);
  }

  String getKeyForCoinHex(TWCoinType coinType) {
    return hex.encode(getKeyForCoin(coinType).data());
  }

  PrivateKey getKey(TWCoinType coinType, String derivationPath) {
    final pointer = HDWalletImpl.getKey(nativehandle, coinType, derivationPath);
    return PrivateKey.pointer(pointer);
  }

  PrivateKey getMasterKey(TWCurve curve) {
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

  String getExtendedPublicKey(
      TWPurpose purpose, TWCoinType coinType, TWHDVersion twHdVersion) {
    return HDWalletImpl.getExtendedPublicKey(
        nativehandle, purpose, coinType, twHdVersion);
  }

  void setName(String name) {
    this.name = name;
  }

  String? getName() {
    return name;
  }

  WalletType getWalletType() {
    return walletType;
  }

  Pointer<Void> getNativeHandle() {
    return nativehandle;
  }
}
