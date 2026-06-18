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
    nativehandle = ffiBridgePrebuilt.tw_lib
        .TWPublicKeyCreateWithData(data, publicKeyType)
        .cast();
  }

  static bool isValid(Uint8List data, TWPublicKeyType publicKeyType) {
    final twData = ffiBridgePrebuilt.tw_lib.TWDataCreateWithBytes(
      data.toPointerUint8(),
      data.length,
    );
    final result = ffiBridgePrebuilt.tw_lib.TWPublicKeyIsValid(
      data.toPointerUint8().cast(),
      publicKeyType,
    );
    ffiBridgePrebuilt.tw_lib.TWDataDelete(twData);
    return result;
  }

  Uint8List data() {
    final data = ffiBridgePrebuilt.tw_lib.TWPublicKeyData(nativehandle.cast());
    return ffiBridgePrebuilt.tw_lib
        .TWDataBytes(data)
        .asTypedList(ffiBridgePrebuilt.tw_lib.TWDataSize(data));
  }

  static Pointer<Void>? recover(Uint8List signature, Uint8List message) {
    final signatureData = ffiBridgePrebuilt.tw_lib.TWDataCreateWithBytes(
      signature.toPointerUint8(),
      signature.length,
    );
    final messageData = ffiBridgePrebuilt.tw_lib.TWDataCreateWithBytes(
      message.toPointerUint8(),
      message.length,
    );
    final result = ffiBridgePrebuilt.tw_lib.TWPublicKeyRecover(
      signatureData,
      messageData,
    );
    if (result.address == 0) {
      return null;
    }
    ffiBridgePrebuilt.tw_lib.TWDataDelete(signatureData);
    ffiBridgePrebuilt.tw_lib.TWDataDelete(messageData);
    return result.cast();
  }

  bool isCompressed() {
    return ffiBridgePrebuilt.tw_lib.TWPublicKeyIsCompressed(
      nativehandle.cast(),
    );
  }

  Pointer<Void> compressed() {
    return ffiBridgePrebuilt.tw_lib
        .TWPublicKeyCompressed(nativehandle.cast())
        .cast();
  }

  Pointer<Void> unCompressed() {
    return ffiBridgePrebuilt.tw_lib
        .TWPublicKeyUncompressed(nativehandle.cast())
        .cast();
  }

  TWPublicKeyType keyType() {
    return ffiBridgePrebuilt.tw_lib.TWPublicKeyKeyType(nativehandle.cast());
  }

  String description() {
    return StringUtil.toDartString(
      ffiBridgePrebuilt.tw_lib
          .TWPublicKeyDescription(nativehandle.cast())
          .cast(),
    );
  }

  void delete() {
    ffiBridgePrebuilt.tw_lib.TWPublicKeyDelete(nativehandle.cast());
    nativehandle = nullptr;
  }

  bool verify(Uint8List signature, Uint8List message) {
    final signatureData = ffiBridgePrebuilt.tw_lib.TWDataCreateWithBytes(
      signature.toPointerUint8(),
      signature.length,
    );
    final messageData = ffiBridgePrebuilt.tw_lib.TWDataCreateWithBytes(
      message.toPointerUint8(),
      message.length,
    );
    final result = ffiBridgePrebuilt.tw_lib.TWPublicKeyVerify(
      nativehandle.cast(),
      signatureData,
      messageData,
    );
    ffiBridgePrebuilt.tw_lib.TWDataDelete(signatureData);
    ffiBridgePrebuilt.tw_lib.TWDataDelete(messageData);
    return result;
  }

  bool verifySchnorr(Uint8List signature, Uint8List message) {
    final signatureData = ffiBridgePrebuilt.tw_lib.TWDataCreateWithBytes(
      signature.toPointerUint8(),
      signature.length,
    );
    final messageData = ffiBridgePrebuilt.tw_lib.TWDataCreateWithBytes(
      message.toPointerUint8(),
      message.length,
    );
    final result = ffiBridgePrebuilt.tw_lib.TWPublicKeyVerifyZilliqaSchnorr(
      nativehandle.cast(),
      signatureData,
      messageData,
    );
    ffiBridgePrebuilt.tw_lib.TWDataDelete(signatureData);
    ffiBridgePrebuilt.tw_lib.TWDataDelete(messageData);
    return result;
  }
}
