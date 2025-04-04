import 'dart:ffi';
import 'dart:typed_data';

import 'package:genius_api/extensions/extensions.dart';
import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/tw/string_util.dart';

class PublicKeyImpl {
  static FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();
  static bool isValid(Uint8List data, int publicKeyType) {
    final twData = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(data.toPointerUint8(), data.length);

    final result = ffiBridgePrebuilt.wallet_lib
        .TWPublicKeyIsValid(data.toPointerUint8().cast(), publicKeyType);

    ffiBridgePrebuilt.wallet_lib.TWDataDelete(twData);
    return result;
  }

  static Pointer<Void> createWithData(Pointer<Void> data, int publicKeyType) {
    final publickey = ffiBridgePrebuilt.wallet_lib
        .TWPublicKeyCreateWithData(data, publicKeyType);

    return publickey.cast();
  }

  static Uint8List data(Pointer<Void> publicKey) {
    final data = ffiBridgePrebuilt.wallet_lib.TWPublicKeyData(publicKey.cast());

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

  static bool isCompressed(Pointer<Void> publicKey) {
    return ffiBridgePrebuilt.wallet_lib
        .TWPublicKeyIsCompressed(publicKey.cast());
  }

  static Pointer<Void> compressed(Pointer<Void> publicKey) {
    return ffiBridgePrebuilt.wallet_lib
        .TWPublicKeyCompressed(publicKey.cast())
        .cast();
  }

  static Pointer<Void> unCompressed(Pointer<Void> publicKey) {
    return ffiBridgePrebuilt.wallet_lib
        .TWPublicKeyUncompressed(publicKey.cast())
        .cast();
  }

  static int keyType(Pointer<Void> publicKey) {
    return ffiBridgePrebuilt.wallet_lib.TWPublicKeyKeyType(publicKey.cast());
  }

  static String description(Pointer<Void> publicKey) {
    return StringUtil.toDartString(ffiBridgePrebuilt.wallet_lib
        .TWPublicKeyDescription(publicKey.cast())
        .cast());
  }

  static void delete(Pointer<Void> publicKey) {
    return ffiBridgePrebuilt.wallet_lib.TWPublicKeyDelete(publicKey.cast());
  }

  static bool verify(
      Pointer<Void> publicKey, Uint8List signature, Uint8List message) {
    final signatureData = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(signature.toPointerUint8(), signature.length);
    final messageData = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(message.toPointerUint8(), message.length);
    final result = ffiBridgePrebuilt.wallet_lib
        .TWPublicKeyVerify(publicKey.cast(), signatureData, messageData);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(signatureData);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(messageData);
    return result;
  }

  static bool verifyZilliqaSchnorr(
      Pointer<Void> publicKey, Uint8List signature, Uint8List message) {
    final signatureData = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(signature.toPointerUint8(), signature.length);
    final messageData = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(message.toPointerUint8(), message.length);
    final result = ffiBridgePrebuilt.wallet_lib.TWPublicKeyVerifyZilliqaSchnorr(
        publicKey.cast(), signatureData, messageData);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(signatureData);
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(messageData);
    return result;
  }
}
