import 'dart:ffi';
import 'dart:typed_data';

import 'package:genius_api/extensions/extensions.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/tw/string_util.dart';

class PublicKey {
  static final FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();
  static const int publicKeyCompressedSize = 33;
  static const int publicKeyUncompressedSize = 65;

  late Pointer<Void> nativehandle;

  Pointer<Void> get pointer => nativehandle;

  PublicKey(Pointer<Void> pointer) {
    nativehandle = pointer;
  }

  PublicKey.createWithData(Pointer<Void> data, TWPublicKeyType publicKeyType) {
    nativehandle = ffiBridgePrebuilt.wallet_lib
        .TWPublicKeyCreateWithData(data, publicKeyType)
        .cast();
  }

  static bool isValid(Uint8List data, TWPublicKeyType publicKeyType) {
    final twData = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(data.toPointerUint8(), data.length);
    final result = ffiBridgePrebuilt.wallet_lib
        .TWPublicKeyIsValid(data.toPointerUint8().cast(), publicKeyType);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(twData);
    return result;
  }

  Uint8List data() {
    final data =
        ffiBridgePrebuilt.wallet_lib.TWPublicKeyData(nativehandle.cast());
    return ffiBridgePrebuilt.wallet_lib
        .TWDataBytes(data)
        .asTypedList(ffiBridgePrebuilt.wallet_lib.TWDataSize(data));
  }

  static Pointer<Void>? recover(Uint8List signature, Uint8List message) {
    final signatureData = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(signature.toPointerUint8(), signature.length);
    final messageData = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(message.toPointerUint8(), message.length);
    final result = ffiBridgePrebuilt.wallet_lib
        .TWPublicKeyRecover(signatureData, messageData);
    if (result.address == 0) {
      return null;
    }
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(signatureData);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(messageData);
    return result.cast();
  }

  bool isCompressed() {
    return ffiBridgePrebuilt.wallet_lib
        .TWPublicKeyIsCompressed(nativehandle.cast());
  }

  Pointer<Void> compressed() {
    return ffiBridgePrebuilt.wallet_lib
        .TWPublicKeyCompressed(nativehandle.cast())
        .cast();
  }

  Pointer<Void> unCompressed() {
    return ffiBridgePrebuilt.wallet_lib
        .TWPublicKeyUncompressed(nativehandle.cast())
        .cast();
  }

  TWPublicKeyType keyType() {
    return ffiBridgePrebuilt.wallet_lib
        .TWPublicKeyKeyType(nativehandle.cast());
  }

  String description() {
    return StringUtil.toDartString(ffiBridgePrebuilt.wallet_lib
        .TWPublicKeyDescription(nativehandle.cast())
        .cast());
  }

  void delete() {
    ffiBridgePrebuilt.wallet_lib.TWPublicKeyDelete(nativehandle.cast());
    nativehandle = nullptr;
  }

  bool verify(Uint8List signature, Uint8List message) {
    final signatureData = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(signature.toPointerUint8(), signature.length);
    final messageData = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(message.toPointerUint8(), message.length);
    final result = ffiBridgePrebuilt.wallet_lib
        .TWPublicKeyVerify(nativehandle.cast(), signatureData, messageData);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(signatureData);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(messageData);
    return result;
  }

  bool verifySchnorr(Uint8List signature, Uint8List message) {
    final signatureData = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(signature.toPointerUint8(), signature.length);
    final messageData = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(message.toPointerUint8(), message.length);
    final result = ffiBridgePrebuilt.wallet_lib.TWPublicKeyVerifyZilliqaSchnorr(
        nativehandle.cast(), signatureData, messageData);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(signatureData);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(messageData);
    return result;
  }
}
