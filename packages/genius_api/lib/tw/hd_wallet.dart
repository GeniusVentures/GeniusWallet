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
    nativehandle = ffiBridgePrebuilt.twLib
        .TWHDWalletCreate(strength, passphraseTWString.cast())
        .cast();
    StringUtil.delete(passphraseTWString);
    if (nativehandle.hashCode == 0) {
      throw Exception(["HDWallet nativehandle is null"]);
    }
  }

  HDWallet.createWithMnemonic(
    String mnemonic, {
    String passphrase = "",
    String walletName = "",
  }) {
    if (!MnemonicImpl.isValid(mnemonic)) {
      throw Exception(["mnemonic is invalid"]);
    }
    final passphraseTWString = StringUtil.toTWString(passphrase);
    final mnemonicTWString = StringUtil.toTWString(mnemonic);
    nativehandle = ffiBridgePrebuilt.twLib
        .TWHDWalletCreateWithMnemonic(
          mnemonicTWString.cast(),
          passphraseTWString.cast(),
        )
        .cast();
    StringUtil.delete(passphraseTWString);
    StringUtil.delete(mnemonicTWString);
    name = walletName;
    if (nativehandle.hashCode == 0) {
      throw Exception(["HDWallet nativehandle is null"]);
    }
  }

  HDWallet.createWithData(Uint8List bytes, {String passphrase = ""}) {
    final data = ffiBridgePrebuilt.twLib.TWDataCreateWithBytes(
      bytes.toPointerUint8(),
      bytes.length,
    );
    final passphraseTWString = StringUtil.toTWString(passphrase);
    nativehandle = ffiBridgePrebuilt.twLib
        .TWHDWalletCreateWithEntropy(data, passphraseTWString.cast())
        .cast();
    StringUtil.delete(passphraseTWString);
    ffiBridgePrebuilt.twLib.TWDataDelete(data);
    if (nativehandle.hashCode == 0) {
      throw Exception(["HDWallet nativehandle is null"]);
    }
  }

  String getAddressForCoin(TWCoinType coinType) {
    final address = ffiBridgePrebuilt.twLib.TWHDWalletGetAddressForCoin(
      nativehandle.cast(),
      coinType,
    );
    return StringUtil.toDartString(address.cast());
  }

  PrivateKey getDerivedKey(
    TWCoinType coinType,
    int account,
    int change,
    int address,
  ) {
    final pointer = ffiBridgePrebuilt.twLib
        .TWHDWalletGetDerivedKey(
          nativehandle.cast(),
          coinType,
          account,
          change,
          address,
        )
        .cast<Void>();
    return PrivateKey.pointer(pointer);
  }

  PrivateKey getKeyForCoin(TWCoinType coinType) {
    final pointer = ffiBridgePrebuilt.twLib
        .TWHDWalletGetKeyForCoin(nativehandle.cast(), coinType)
        .cast<Void>();
    return PrivateKey.pointer(pointer);
  }

  String getKeyForCoinHex(TWCoinType coinType) {
    return hex.encode(getKeyForCoin(coinType).data());
  }

  PrivateKey getKey(TWCoinType coinType, String derivationPath) {
    final twDerivationPath = StringUtil.toTWString(derivationPath);
    final pointer = ffiBridgePrebuilt.twLib
        .TWHDWalletGetKey(
          nativehandle.cast(),
          coinType,
          twDerivationPath.cast(),
        )
        .cast<Void>();
    StringUtil.delete(twDerivationPath);
    return PrivateKey.pointer(pointer);
  }

  PrivateKey getMasterKey(TWCurve curve) {
    final pointer = ffiBridgePrebuilt.twLib
        .TWHDWalletGetMasterKey(nativehandle.cast(), curve)
        .cast<Void>();
    return PrivateKey.pointer(pointer);
  }

  void delete() {
    ffiBridgePrebuilt.twLib.TWHDWalletDelete(nativehandle.cast());
  }

  Uint8List seed() {
    final data = ffiBridgePrebuilt.twLib.TWHDWalletSeed(nativehandle.cast());
    return ffiBridgePrebuilt.twLib
        .TWDataBytes(data)
        .asTypedList(ffiBridgePrebuilt.twLib.TWDataSize(data));
  }

  String mnemonic() {
    return StringUtil.toDartString(
      ffiBridgePrebuilt.twLib.TWHDWalletMnemonic(nativehandle.cast()).cast(),
    );
  }

  String getExtendedPublicKey(
    TWPurpose purpose,
    TWCoinType coinType,
    TWHDVersion twHdVersion,
  ) {
    final publicKey = ffiBridgePrebuilt.twLib.TWHDWalletGetExtendedPublicKey(
      nativehandle.cast(),
      purpose,
      coinType,
      twHdVersion,
    );
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
