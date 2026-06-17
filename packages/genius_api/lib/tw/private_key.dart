import 'dart:ffi';
import 'dart:typed_data';

import 'package:genius_api/extensions/extensions.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/tw/public_key.dart';

class PrivateKey {
  static final FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();
  static const int privateKeySize = 32;

  late Pointer<Void> nativehandle;

  static bool isValid(Uint8List data, TWCurve curve) {
    return ffiBridgePrebuilt.tw_lib.TWPrivateKeyIsValid(
      ffiBridgePrebuilt.tw_lib.TWDataCreateWithBytes(
        data.toPointerUint8(),
        data.length,
      ),
      curve,
    );
  }

  PrivateKey.pointer(Pointer<Void> pointer) {
    nativehandle = pointer;
  }

  PrivateKey() {
    nativehandle = ffiBridgePrebuilt.tw_lib.TWPrivateKeyCreate().cast();
    if (nativehandle.hashCode == 0) {
      throw Exception(["PrivateKey nativehandle is null"]);
    }
  }

  PrivateKey.createWithData(Uint8List bytes) {
    final data = ffiBridgePrebuilt.tw_lib.TWDataCreateWithBytes(
      bytes.toPointerUint8(),
      bytes.length,
    );
    nativehandle = ffiBridgePrebuilt.tw_lib
        .TWPrivateKeyCreateWithData(data)
        .cast();
    if (nativehandle.hashCode == 0) {
      throw Exception(["PrivateKey nativehandle is null"]);
    }
  }

  PrivateKey.createCopy(Pointer<Void> key) {
    nativehandle = ffiBridgePrebuilt.tw_lib
        .TWPrivateKeyCreateCopy(key.cast())
        .cast();
    if (nativehandle.hashCode == 0) {
      throw Exception(["PrivateKey nativehandle is null"]);
    }
  }

  Uint8List data() {
    final data = ffiBridgePrebuilt.tw_lib.TWPrivateKeyData(nativehandle.cast());
    return ffiBridgePrebuilt.tw_lib
        .TWDataBytes(data)
        .asTypedList(ffiBridgePrebuilt.tw_lib.TWDataSize(data));
  }

  PublicKey getTWPublicKey(TWCurve curve, [bool compressed = false]) {
    switch (curve) {
      case TWCurve.TWCurveSECP256k1:
        return getTWPublicKeySecp256k1(compressed);
      case TWCurve.TWCurveED25519:
        return getTWPublicKeyNistEd25519();
      case TWCurve.TWCurveED25519Blake2bNano:
        return getTWPublicKeyNistEd25519Blake2b();
      case TWCurve.TWCurveCurve25519:
        return getTWPublicKeyCurve25519();
      case TWCurve.TWCurveNIST256p1:
        return getTWPublicKeyNist256p1();
      case TWCurve.TWCurveED25519ExtendedCardano:
        return getTWPublicKeyEd25519Cardano();
      default:
        return getTWPublicKeySecp256k1(compressed);
    }
  }

  PublicKey getTWPublicKeySecp256k1(bool compressed) {
    final data = ffiBridgePrebuilt.tw_lib.TWPrivateKeyGetPublicKeySecp256k1(
      nativehandle.cast(),
      compressed,
    );
    return PublicKey(data.cast());
  }

  PublicKey getTWPublicKeyNist256p1() {
    final data = ffiBridgePrebuilt.tw_lib.TWPrivateKeyGetPublicKeyNist256p1(
      nativehandle.cast(),
    );
    return PublicKey(data.cast());
  }

  PublicKey getTWPublicKeyNistEd25519() {
    final data = ffiBridgePrebuilt.tw_lib.TWPrivateKeyGetPublicKeyEd25519(
      nativehandle.cast(),
    );
    return PublicKey(data.cast());
  }

  PublicKey getTWPublicKeyNistEd25519Blake2b() {
    final data = ffiBridgePrebuilt.tw_lib
        .TWPrivateKeyGetPublicKeyEd25519Blake2b(nativehandle.cast());
    return PublicKey(data.cast());
  }

  PublicKey getTWPublicKeyEd25519Cardano() {
    final data = ffiBridgePrebuilt.tw_lib
        .TWPrivateKeyGetPublicKeyEd25519Cardano(nativehandle.cast());
    return PublicKey(data.cast());
  }

  PublicKey getTWPublicKeyCurve25519() {
    final data = ffiBridgePrebuilt.tw_lib.TWPrivateKeyGetPublicKeyCurve25519(
      nativehandle.cast(),
    );
    return PublicKey(data.cast());
  }

  PublicKey getShareKey(PublicKey twPublicKey, TWCurve curve) {
    final data = ffiBridgePrebuilt.tw_lib.TWPrivateKeyGetSharedKey(
      nativehandle.cast(),
      twPublicKey.pointer.cast(),
      curve,
    );
    return PublicKey(data);
  }

  Uint8List sign(Uint8List digest, TWCurve curve) {
    final digestPoint = ffiBridgePrebuilt.tw_lib.TWDataCreateWithBytes(
      digest.toPointerUint8(),
      digest.length,
    );
    final data = ffiBridgePrebuilt.tw_lib.TWPrivateKeySign(
      nativehandle.cast(),
      digestPoint,
      curve,
    );
    final res = ffiBridgePrebuilt.tw_lib
        .TWDataBytes(data)
        .asTypedList(ffiBridgePrebuilt.tw_lib.TWDataSize(data));
    ffiBridgePrebuilt.tw_lib.TWDataDelete(digestPoint);
    return res;
  }

  Uint8List signAsDER(Uint8List digest) {
    final digestPoint = ffiBridgePrebuilt.tw_lib.TWDataCreateWithBytes(
      digest.toPointerUint8(),
      digest.length,
    );
    final data = ffiBridgePrebuilt.tw_lib.TWPrivateKeySignAsDER(
      nativehandle.cast(),
      digestPoint,
    );
    final res = ffiBridgePrebuilt.tw_lib
        .TWDataBytes(data)
        .asTypedList(ffiBridgePrebuilt.tw_lib.TWDataSize(data));
    ffiBridgePrebuilt.tw_lib.TWDataDelete(digestPoint);
    return res;
  }

  Uint8List signZilliqaSchnorr(Uint8List digest) {
    final digestPoint = ffiBridgePrebuilt.tw_lib.TWDataCreateWithBytes(
      digest.toPointerUint8(),
      digest.length,
    );
    final data = ffiBridgePrebuilt.tw_lib.TWPrivateKeySignZilliqaSchnorr(
      nativehandle.cast(),
      digestPoint,
    );
    final res = ffiBridgePrebuilt.tw_lib
        .TWDataBytes(data)
        .asTypedList(ffiBridgePrebuilt.tw_lib.TWDataSize(data));
    ffiBridgePrebuilt.tw_lib.TWDataDelete(digestPoint);
    return res;
  }

  void delete() {
    ffiBridgePrebuilt.tw_lib.TWPrivateKeyDelete(nativehandle.cast());
    nativehandle = nullptr;
  }
}
