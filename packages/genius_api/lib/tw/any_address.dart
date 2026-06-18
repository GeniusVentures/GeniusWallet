import 'dart:ffi';
import 'dart:typed_data';

import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/tw/private_key.dart';
import 'package:genius_api/tw/public_key.dart';
import 'package:genius_api/tw/string_util.dart';

/// Create any type of wallet address for a multi HD Wallet
class AnyAddress {
  static final FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();
  late Pointer<Void> nativehandle;

  AnyAddress.createWithString(String address, TWCoinType coinType) {
    final twAddress = StringUtil.toTWString(address);
    nativehandle = ffiBridgePrebuilt.tw_lib
        .TWAnyAddressCreateWithString(twAddress.cast(), coinType)
        .cast();
    StringUtil.delete(twAddress);
  }

  AnyAddress.createWithPublicKey(PublicKey publicKey, TWCoinType coinType) {
    nativehandle = ffiBridgePrebuilt.tw_lib
        .TWAnyAddressCreateWithPublicKey(
          publicKey.nativehandle.cast(),
          coinType,
        )
        .cast();
  }

  AnyAddress.createWithPrivateKeyData(
    Uint8List privateKeyData,
    TWCoinType coinType,
    TWCurve curve,
  ) {
    PrivateKey pk = PrivateKey.createWithData(privateKeyData);
    PublicKey publicKey = pk.getTWPublicKey(curve);
    nativehandle = ffiBridgePrebuilt.tw_lib
        .TWAnyAddressCreateWithPublicKey(
          publicKey.nativehandle.cast(),
          coinType,
        )
        .cast();
  }

  static bool isValid(String address, TWCoinType coinType) {
    final twAddress = StringUtil.toTWString(address);
    final result = ffiBridgePrebuilt.tw_lib.TWAnyAddressIsValid(
      twAddress.cast(),
      coinType,
    );
    StringUtil.delete(twAddress);
    return result;
  }

  Uint8List data() {
    final addressData = ffiBridgePrebuilt.tw_lib.TWAnyAddressData(
      nativehandle.cast(),
    );
    return ffiBridgePrebuilt.tw_lib
        .TWDataBytes(addressData)
        .asTypedList(ffiBridgePrebuilt.tw_lib.TWDataSize(addressData));
  }

  String description() {
    final twString = ffiBridgePrebuilt.tw_lib.TWAnyAddressDescription(
      nativehandle.cast(),
    );
    return StringUtil.toDartString(twString.cast());
  }

  void delete() {
    ffiBridgePrebuilt.tw_lib.TWAnyAddressDelete(nativehandle.cast());
    nativehandle = nullptr;
  }
}
