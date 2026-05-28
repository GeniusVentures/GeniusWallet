import 'dart:ffi';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:genius_api/extensions/extensions.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/tw/mnemonic_impl.dart';
import 'package:genius_api/tw/private_key.dart';
import 'package:genius_api/tw/string_util.dart';
import 'package:genius_api/types/wallet_type.dart';

class HDWallet {
  static final FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();
  late Pointer<Void> nativehandle;
  final WalletType walletType = WalletType.mnemonic;
  String? name;

  HDWallet.pointer(Pointer<Void> pointer) {
    nativehandle = pointer;
  }

  HDWallet({int strength = 128, String passphrase = ""}) {
    assert(strength >= 128 && strength <= 256 && strength % 32 == 0);
    final passphraseTWString = StringUtil.toTWString(passphrase);
    nativehandle = ffiBridgePrebuilt.tw_lib
        .TWHDWalletCreate(strength, passphraseTWString.cast())
        .cast();
    StringUtil.delete(passphraseTWString);
    if (nativehandle.hashCode == 0) {
      throw Exception(["HDWallet nativehandle is null"]);
    }
  }

  HDWallet.createWithMnemonic(String mnemonic,
      {String passphrase = "", String walletName = ""}) {
    if (!MnemonicImpl.isValid(mnemonic)) {
      throw Exception(["mnemonic is invalid"]);
    }
    final passphraseTWString = StringUtil.toTWString(passphrase);
    final mnemonicTWString = StringUtil.toTWString(mnemonic);
    nativehandle = ffiBridgePrebuilt.tw_lib
        .TWHDWalletCreateWithMnemonic(
            mnemonicTWString.cast(), passphraseTWString.cast())
        .cast();
    StringUtil.delete(passphraseTWString);
    StringUtil.delete(mnemonicTWString);
    name = walletName;
    if (nativehandle.hashCode == 0) {
      throw Exception(["HDWallet nativehandle is null"]);
    }
  }

  HDWallet.createWithData(Uint8List bytes, {String passphrase = ""}) {
    final data = ffiBridgePrebuilt.tw_lib
        .TWDataCreateWithBytes(bytes.toPointerUint8(), bytes.length);
    final passphraseTWString = StringUtil.toTWString(passphrase);
    nativehandle = ffiBridgePrebuilt.tw_lib
        .TWHDWalletCreateWithEntropy(data, passphraseTWString.cast())
        .cast();
    StringUtil.delete(passphraseTWString);
    ffiBridgePrebuilt.tw_lib.TWDataDelete(data);
    if (nativehandle.hashCode == 0) {
      throw Exception(["HDWallet nativehandle is null"]);
    }
  }

  String getAddressForCoin(TWCoinType coinType) {
    final address = ffiBridgePrebuilt.tw_lib
        .TWHDWalletGetAddressForCoin(nativehandle.cast(), coinType);
    return StringUtil.toDartString(address.cast());
  }

  PrivateKey getDerivedKey(
      TWCoinType coinType, int account, int change, int address) {
    final pointer = ffiBridgePrebuilt.tw_lib
        .TWHDWalletGetDerivedKey(
            nativehandle.cast(), coinType, account, change, address)
        .cast<Void>();
    return PrivateKey.pointer(pointer);
  }

  PrivateKey getKeyForCoin(TWCoinType coinType) {
    final pointer = ffiBridgePrebuilt.tw_lib
        .TWHDWalletGetKeyForCoin(nativehandle.cast(), coinType)
        .cast<Void>();
    return PrivateKey.pointer(pointer);
  }

  String getKeyForCoinHex(TWCoinType coinType) {
    return hex.encode(getKeyForCoin(coinType).data());
  }

  PrivateKey getKey(TWCoinType coinType, String derivationPath) {
    final twDerivationPath = StringUtil.toTWString(derivationPath);
    final pointer = ffiBridgePrebuilt.tw_lib
        .TWHDWalletGetKey(
            nativehandle.cast(), coinType, twDerivationPath.cast())
        .cast<Void>();
    StringUtil.delete(twDerivationPath);
    return PrivateKey.pointer(pointer);
  }

  PrivateKey getMasterKey(TWCurve curve) {
    final pointer = ffiBridgePrebuilt.tw_lib
        .TWHDWalletGetMasterKey(nativehandle.cast(), curve)
        .cast<Void>();
    return PrivateKey.pointer(pointer);
  }

  void delete() {
    ffiBridgePrebuilt.tw_lib.TWHDWalletDelete(nativehandle.cast());
  }

  Uint8List seed() {
    final data =
        ffiBridgePrebuilt.tw_lib.TWHDWalletSeed(nativehandle.cast());
    return ffiBridgePrebuilt.tw_lib
        .TWDataBytes(data)
        .asTypedList(ffiBridgePrebuilt.tw_lib.TWDataSize(data));
  }

  String mnemonic() {
    return StringUtil.toDartString(ffiBridgePrebuilt.tw_lib
        .TWHDWalletMnemonic(nativehandle.cast())
        .cast());
  }

  String getExtendedPublicKey(
      TWPurpose purpose, TWCoinType coinType, TWHDVersion twHdVersion) {
    final publicKey = ffiBridgePrebuilt.tw_lib
        .TWHDWalletGetExtendedPublicKey(
            nativehandle.cast(), purpose, coinType, twHdVersion);
    return StringUtil.toDartString(publicKey.cast());
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
