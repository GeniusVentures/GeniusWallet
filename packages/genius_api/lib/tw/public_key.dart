import 'dart:ffi';
import 'dart:typed_data';

import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/tw/public_key_impl.dart';

class PublicKey {
  static FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();
  static const int publicKeyCompressedSize = 33;
  static const int publicKeyUncompressedSize = 65;

  late Pointer<Void> nativehandle;

  Pointer<Void> get pointer => nativehandle;

  PublicKey(Pointer<Void> pointer) {
    nativehandle = pointer;
  }

  PublicKey.createWithData(Pointer<Void> data, int publicKeyType) {
    nativehandle = ffiBridgePrebuilt.wallet_lib
        .TWPublicKeyCreateWithData(data, publicKeyType)
        .cast();
  }

  static bool isValid(Uint8List data, int publicKeyType) {
    return PublicKeyImpl.isValid(data, publicKeyType);
  }

  Uint8List data() {
    return PublicKeyImpl.data(nativehandle);
  }

  static Pointer<Void>? recover(Uint8List signature, Uint8List message) {
    return PublicKeyImpl.recover(signature, message);
  }

  bool isCompressed() {
    return PublicKeyImpl.isCompressed(nativehandle);
  }

  Pointer<Void> compressed() {
    return PublicKeyImpl.compressed(nativehandle);
  }

  Pointer<Void> unCompressed() {
    return PublicKeyImpl.unCompressed(nativehandle);
  }

  int keyType() {
    return PublicKeyImpl.keyType(nativehandle);
  }

  String description() {
    return PublicKeyImpl.description(nativehandle);
  }

  void delete() {
    PublicKeyImpl.delete(nativehandle);
    nativehandle = nullptr;
  }

  bool verify(Uint8List signature, Uint8List message) {
    return PublicKeyImpl.verify(nativehandle, signature, message);
  }

  bool verifySchnorr(Uint8List signature, Uint8List message) {
    return PublicKeyImpl.verifyZilliqaSchnorr(nativehandle, signature, message);
  }
}
