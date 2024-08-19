import 'dart:ffi';
import 'dart:typed_data';

import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/tw/any_address_impl.dart';
import 'package:genius_api/tw/private_key.dart';
import 'package:genius_api/tw/public_key.dart';

/// Create any type of wallet address for a multi HD Wallet
class AnyAddress {
  static FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();
  late Pointer<Void> pointer;

  AnyAddress.createWithString(String address, int coinType) {
    pointer = AnyAddressImpl.createWithString(address, coinType);
  }

  AnyAddress.createWithPublicKey(PublicKey publicKey, int coinType) {
    pointer =
        AnyAddressImpl.createWithPublicKey(publicKey.nativehandle, coinType);
  }

  AnyAddress.createWithPrivateKeyData(
      Uint8List privateKeyData, int coinType, int curve) {
    PrivateKey pk = PrivateKey.createWithData(privateKeyData);
    PublicKey publicKey = pk.getTWPublicKey(curve);
    pointer =
        AnyAddressImpl.createWithPublicKey(publicKey.nativehandle, coinType);
  }

  static bool isValid(String address, int coinType) {
    return AnyAddressImpl.isValid(address, coinType);
  }

  Uint8List data() {
    return AnyAddressImpl.data(pointer);
  }

  String description() {
    return AnyAddressImpl.description(pointer);
  }

  void delete() {
    AnyAddressImpl.delete(pointer);
    pointer = nullptr;
  }
}
