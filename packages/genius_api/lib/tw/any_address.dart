import 'dart:ffi';
import 'dart:typed_data';

import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/tw/any_address_impl.dart';
import 'package:genius_api/tw/private_key.dart';
import 'package:genius_api/tw/public_key.dart';

/// Create any type of wallet address for a multi HD Wallet
class AnyAddress {
  static FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();
  late Pointer<Void> nativehandle;

  AnyAddress.createWithString(String address, TWCoinType coinType) {
    nativehandle = AnyAddressImpl.createWithString(address, coinType);
  }

  AnyAddress.createWithPublicKey(PublicKey publicKey, TWCoinType coinType) {
    nativehandle =
        AnyAddressImpl.createWithPublicKey(publicKey.nativehandle, coinType);
  }

  AnyAddress.createWithPrivateKeyData(
      Uint8List privateKeyData, TWCoinType coinType, TWCurve curve) {
    PrivateKey pk = PrivateKey.createWithData(privateKeyData);
    PublicKey publicKey = pk.getTWPublicKey(curve);
    nativehandle =
        AnyAddressImpl.createWithPublicKey(publicKey.nativehandle, coinType);
  }

  static bool isValid(String address, TWCoinType coinType) {
    return AnyAddressImpl.isValid(address, coinType);
  }

  Uint8List data() {
    return AnyAddressImpl.data(nativehandle);
  }

  String description() {
    return AnyAddressImpl.description(nativehandle);
  }

  void delete() {
    AnyAddressImpl.delete(nativehandle);
    nativehandle = nullptr;
  }
}
