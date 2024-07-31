import 'dart:ffi';
import 'dart:typed_data';

import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/impl/tw_public_key_impl.dart';

class TWPublicKey {
  static FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();
  static const int publicKeyCompressedSize = 33;
  static const int publicKeyUncompressedSize = 65;

  late Pointer<Void> _nativehandle;

  Pointer<Void> get pointer => _nativehandle;

  TWPublicKey(Pointer<Void> pointer) {
    _nativehandle = pointer;
  }

  TWPublicKey.createWithData(Pointer<Void> data, int publicKeyType) {
    _nativehandle = ffiBridgePrebuilt.wallet_lib
        .TWPublicKeyCreateWithData(data, publicKeyType)
        .cast();
  }

  static bool isValid(Uint8List data, int publivKeyType) {
    return TWPublicKeyImpl.isValid(data, publivKeyType);
  }

  Uint8List data() {
    return TWPublicKeyImpl.data(_nativehandle);
  }

  static Pointer<Void>? recover(Uint8List signature, Uint8List message) {
    return TWPublicKeyImpl.recover(signature, message);
  }

  bool isCompressed() {
    return TWPublicKeyImpl.isCompressed(_nativehandle);
  }

  Pointer<Void> compressed() {
    return TWPublicKeyImpl.compressed(_nativehandle);
  }

  Pointer<Void> unCompressed() {
    return TWPublicKeyImpl.unCompressed(_nativehandle);
  }

  int keyType() {
    return TWPublicKeyImpl.keyType(_nativehandle);
  }

  String description() {
    return TWPublicKeyImpl.description(_nativehandle);
  }

  void delete() {
    TWPublicKeyImpl.delete(_nativehandle);
    _nativehandle = nullptr;
  }

  bool verify(Uint8List signature, Uint8List message) {
    return TWPublicKeyImpl.verify(_nativehandle, signature, message);
  }

  bool verifySchnorr(Uint8List signature, Uint8List message) {
    return TWPublicKeyImpl.verifyZilliqaSchnorr(
        _nativehandle, signature, message);
  }
}
