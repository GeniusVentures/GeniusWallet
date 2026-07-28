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
    nativehandle = ffiBridgePrebuilt.twLib
        .TWPublicKeyCreateWithData(data, publicKeyType)
        .cast();
  }

  static bool isValid(Uint8List data, TWPublicKeyType publicKeyType) {
    final twData = ffiBridgePrebuilt.twLib.TWDataCreateWithBytes(
      data.toPointerUint8(),
      data.length,
    );
    final result = ffiBridgePrebuilt.twLib.TWPublicKeyIsValid(
      data.toPointerUint8().cast(),
      publicKeyType,
    );
    ffiBridgePrebuilt.twLib.TWDataDelete(twData);
    return result;
  }

  Uint8List data() {
    final data = ffiBridgePrebuilt.twLib.TWPublicKeyData(nativehandle.cast());
    return ffiBridgePrebuilt.twLib
        .TWDataBytes(data)
        .asTypedList(ffiBridgePrebuilt.twLib.TWDataSize(data));
  }

  static Pointer<Void>? recover(Uint8List signature, Uint8List message) {
    final signatureData = ffiBridgePrebuilt.twLib.TWDataCreateWithBytes(
      signature.toPointerUint8(),
      signature.length,
    );
    final messageData = ffiBridgePrebuilt.twLib.TWDataCreateWithBytes(
      message.toPointerUint8(),
      message.length,
    );
    final result = ffiBridgePrebuilt.twLib.TWPublicKeyRecover(
      signatureData,
      messageData,
    );
    if (result.address == 0) {
      return null;
    }
    ffiBridgePrebuilt.twLib.TWDataDelete(signatureData);
    ffiBridgePrebuilt.twLib.TWDataDelete(messageData);
    return result.cast();
  }

  bool isCompressed() {
    return ffiBridgePrebuilt.twLib.TWPublicKeyIsCompressed(
      nativehandle.cast(),
    );
  }

  Pointer<Void> compressed() {
    return ffiBridgePrebuilt.twLib
        .TWPublicKeyCompressed(nativehandle.cast())
        .cast();
  }

  Pointer<Void> unCompressed() {
    return ffiBridgePrebuilt.twLib
        .TWPublicKeyUncompressed(nativehandle.cast())
        .cast();
  }

  TWPublicKeyType keyType() {
    return ffiBridgePrebuilt.twLib.TWPublicKeyKeyType(nativehandle.cast());
  }

  String description() {
    return StringUtil.toDartString(
      ffiBridgePrebuilt.twLib
          .TWPublicKeyDescription(nativehandle.cast())
          .cast(),
    );
  }

  void delete() {
    ffiBridgePrebuilt.twLib.TWPublicKeyDelete(nativehandle.cast());
    nativehandle = nullptr;
  }

  bool verify(Uint8List signature, Uint8List message) {
    final signatureData = ffiBridgePrebuilt.twLib.TWDataCreateWithBytes(
      signature.toPointerUint8(),
      signature.length,
    );
    final messageData = ffiBridgePrebuilt.twLib.TWDataCreateWithBytes(
      message.toPointerUint8(),
      message.length,
    );
    final result = ffiBridgePrebuilt.twLib.TWPublicKeyVerify(
      nativehandle.cast(),
      signatureData,
      messageData,
    );
    ffiBridgePrebuilt.twLib.TWDataDelete(signatureData);
    ffiBridgePrebuilt.twLib.TWDataDelete(messageData);
    return result;
  }

  bool verifySchnorr(Uint8List signature, Uint8List message) {
    final signatureData = ffiBridgePrebuilt.twLib.TWDataCreateWithBytes(
      signature.toPointerUint8(),
      signature.length,
    );
    final messageData = ffiBridgePrebuilt.twLib.TWDataCreateWithBytes(
      message.toPointerUint8(),
      message.length,
    );
    final result = ffiBridgePrebuilt.twLib.TWPublicKeyVerifyZilliqaSchnorr(
      nativehandle.cast(),
      signatureData,
      messageData,
    );
    ffiBridgePrebuilt.twLib.TWDataDelete(signatureData);
    ffiBridgePrebuilt.twLib.TWDataDelete(messageData);
    return result;
  }
}
