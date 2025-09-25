import 'dart:ffi';
import 'dart:typed_data';

import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/tw/string_util.dart';

import '../ffi/trust_wallet_api_ffi.dart';

class AnyAddressImpl {
  static FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();
  static bool isValid(String address, TWCoinType coinType) {
    final twAddress = StringUtil.toTWString(address);
    final result = ffiBridgePrebuilt.wallet_lib
        .TWAnyAddressIsValid(twAddress.cast(), coinType);
    StringUtil.delete(twAddress);
    return result;
  }

  static Pointer<Void> createWithString(String address, TWCoinType coinType) {
    final twAddress = StringUtil.toTWString(address);
    final result = ffiBridgePrebuilt.wallet_lib
        .TWAnyAddressCreateWithString(twAddress.cast(), coinType);
    StringUtil.delete(twAddress);
    return result.cast();
  }

  static Pointer<Void> createWithPublicKey(
      Pointer<Void> publicKey, TWCoinType coinType) {
    final result = ffiBridgePrebuilt.wallet_lib
        .TWAnyAddressCreateWithPublicKey(publicKey.cast(), coinType);
    return result.cast();
  }

  static Uint8List data(Pointer<Void> anyAddress) {
    final addressData =
        ffiBridgePrebuilt.wallet_lib.TWAnyAddressData(anyAddress.cast());

    final result = ffiBridgePrebuilt.wallet_lib
        .TWDataBytes(addressData)
        .asTypedList(ffiBridgePrebuilt.wallet_lib.TWDataSize(addressData));
    return result;
  }

  static String description(Pointer<Void> anyAddress) {
    final twString =
        ffiBridgePrebuilt.wallet_lib.TWAnyAddressDescription(anyAddress.cast());
    return StringUtil.toDartString(twString.cast());
  }

  static void delete(Pointer<Void> address) {
    ffiBridgePrebuilt.wallet_lib.TWAnyAddressDelete(address.cast());
  }
}
