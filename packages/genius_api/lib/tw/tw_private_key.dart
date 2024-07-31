import 'dart:ffi';
import 'dart:typed_data';

import 'package:genius_api/extensions/extensions.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart' as ffi;
import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/impl/tw_private_key_impl.dart';
import 'package:genius_api/impl/tw_public_key.dart';

class TWPrivateKey {
  static FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();
  static const int privateKeySize = 32;

  late Pointer<Void> _nativehandle;

  static bool isValid(Uint8List data, int curve) {
    return TWPrivateKeyImpl.isValid(
        ffiBridgePrebuilt.wallet_lib
            .TWDataCreateWithBytes(data.toPointerUint8(), data.length),
        curve);
  }

  TWPrivateKey.pointer(Pointer<Void> pointer) {
    _nativehandle = pointer;
  }

  TWPrivateKey() {
    _nativehandle = TWPrivateKeyImpl.create();
    if (_nativehandle.hashCode == 0) {
      throw Exception(["PrivateKey nativehandle is null"]);
    }
  }

  TWPrivateKey.createWithData(Uint8List bytes) {
    _nativehandle = TWPrivateKeyImpl.createWithData(bytes);
    if (_nativehandle.hashCode == 0) {
      throw Exception(["PrivateKey nativehandle is null"]);
    }
  }

  TWPrivateKey.createCopy(Pointer<Void> key) {
    _nativehandle = TWPrivateKeyImpl.createCopy(key);
    if (_nativehandle.hashCode == 0) {
      throw Exception(["PrivateKey nativehandle is null"]);
    }
  }

  Uint8List data() {
    final data = TWPrivateKeyImpl.data(_nativehandle);
    return ffiBridgePrebuilt.wallet_lib
        .TWDataBytes(data)
        .asTypedList(ffiBridgePrebuilt.wallet_lib.TWDataSize(data));
  }

  TWPublicKey getTWPublicKey(int curve, [bool compressed = false]) {
    switch (curve) {
      case ffi.TWCurve.TWCurveSECP256k1:
        return getTWPublicKeySecp256k1(compressed);
      case ffi.TWCurve.TWCurveED25519:
        return getTWPublicKeyNistEd25519();
      case ffi.TWCurve.TWCurveED25519Blake2bNano:
        return getTWPublicKeyNistEd25519Blake2b();
      case ffi.TWCurve.TWCurveCurve25519:
        return getTWPublicKeyCurve25519();
      case ffi.TWCurve.TWCurveNIST256p1:
        return getTWPublicKeyNist256p1();
      case ffi.TWCurve.TWCurveED25519ExtendedCardano:
        return getTWPublicKeyEd25519Cardano();
      default:
        return getTWPublicKeySecp256k1(compressed);
    }
  }

  TWPublicKey getTWPublicKeySecp256k1(bool compressed) {
    final data = ffiBridgePrebuilt.wallet_lib
        .TWPrivateKeyGetPublicKeySecp256k1(_nativehandle.cast(), compressed);
    return TWPublicKey(data.cast());
  }

  TWPublicKey getTWPublicKeyNist256p1() {
    final data = ffiBridgePrebuilt.wallet_lib
        .TWPrivateKeyGetPublicKeyNist256p1(_nativehandle.cast());
    return TWPublicKey(data.cast());
  }

  TWPublicKey getTWPublicKeyNistEd25519() {
    final data = ffiBridgePrebuilt.wallet_lib
        .TWPrivateKeyGetPublicKeyEd25519(_nativehandle.cast());
    return TWPublicKey(data.cast());
  }

  TWPublicKey getTWPublicKeyNistEd25519Blake2b() {
    final data = ffiBridgePrebuilt.wallet_lib
        .TWPrivateKeyGetPublicKeyEd25519Blake2b(_nativehandle.cast());
    return TWPublicKey(data.cast());
  }

  TWPublicKey getTWPublicKeyEd25519Cardano() {
    final data = ffiBridgePrebuilt.wallet_lib
        .TWPrivateKeyGetPublicKeyEd25519Cardano(_nativehandle.cast());
    return TWPublicKey(data.cast());
  }

  TWPublicKey getTWPublicKeyCurve25519() {
    final data = ffiBridgePrebuilt.wallet_lib
        .TWPrivateKeyGetPublicKeyCurve25519(_nativehandle.cast());
    return TWPublicKey(data.cast());
  }

  TWPublicKey getShareKey(TWPublicKey twPublicKey, int curve) {
    final data =
        TWPrivateKeyImpl.getShareKey(_nativehandle, twPublicKey.pointer, curve);
    return TWPublicKey(data);
  }

  Uint8List sign(Uint8List digest, int curve) {
    final digestPoint = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(digest.toPointerUint8(), digest.length);
    final data = TWPrivateKeyImpl.sign(_nativehandle, digestPoint, curve);
    final res = ffiBridgePrebuilt.wallet_lib
        .TWDataBytes(data)
        .asTypedList(ffiBridgePrebuilt.wallet_lib.TWDataSize(data));
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(digestPoint);
    return res;
  }

  Uint8List signAsDER(Uint8List digest, int curve) {
    final digestPoint = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(digest.toPointerUint8(), digest.length);
    final data = TWPrivateKeyImpl.signAsDER(_nativehandle, digestPoint);
    final res = ffiBridgePrebuilt.wallet_lib
        .TWDataBytes(data)
        .asTypedList(ffiBridgePrebuilt.wallet_lib.TWDataSize(data));
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(digestPoint);
    return res;
  }

  Uint8List signZilliqaSchnorr(Uint8List digest) {
    final digestPoint = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(digest.toPointerUint8(), digest.length);
    final data =
        TWPrivateKeyImpl.signZilliqaSchnorr(_nativehandle, digestPoint);
    final res = ffiBridgePrebuilt.wallet_lib
        .TWDataBytes(data)
        .asTypedList(ffiBridgePrebuilt.wallet_lib.TWDataSize(data));
    ffiBridgePrebuilt.wallet_lib.TWDataDelete(digestPoint);
    return res;
  }

  void delete() {
    TWPrivateKeyImpl.delete(_nativehandle);
    _nativehandle = nullptr;
  }
}
