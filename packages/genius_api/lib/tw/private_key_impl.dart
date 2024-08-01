import 'dart:ffi';
import 'dart:typed_data';

import 'package:genius_api/extensions/extensions.dart';
import 'package:genius_api/ffi_bridge_prebuilt.dart';

class PrivateKeyImpl {
  static FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();
  static Pointer<Void> create() {
    return ffiBridgePrebuilt.wallet_lib.TWPrivateKeyCreate().cast();
  }

  static Pointer<Void> createWithData(Uint8List bytes) {
    final data = ffiBridgePrebuilt.wallet_lib
        .TWDataCreateWithBytes(bytes.toPointerUint8(), bytes.length);
    return ffiBridgePrebuilt.wallet_lib.TWPrivateKeyCreateWithData(data).cast();
  }

  static Pointer<Void> createCopy(Pointer<Void> key) {
    return ffiBridgePrebuilt.wallet_lib
        .TWPrivateKeyCreateCopy(key.cast())
        .cast();
  }

  static Pointer<Void> data(Pointer<Void> pk) {
    return ffiBridgePrebuilt.wallet_lib.TWPrivateKeyData(pk.cast());
  }

  static bool isValid(Pointer<Void> data, int curve) {
    return ffiBridgePrebuilt.wallet_lib.TWPrivateKeyIsValid(data, curve);
  }

  static void delete(Pointer<Void> pk) {
    ffiBridgePrebuilt.wallet_lib.TWPrivateKeyDelete(pk.cast());
  }

  static Pointer<Void> getPublicKeySecp256k1(
      Pointer<Void> pk, bool compressed) {
    return ffiBridgePrebuilt.wallet_lib
        .TWPrivateKeyGetPublicKeySecp256k1(pk.cast(), compressed)
        .cast();
  }

  static Pointer<Void> getPublicKeyNist256p1(Pointer<Void> pk) {
    return ffiBridgePrebuilt.wallet_lib
        .TWPrivateKeyGetPublicKeyNist256p1(pk.cast())
        .cast();
  }

  static Pointer<Void> getPublicKeyNistEd25519(Pointer<Void> pk) {
    return ffiBridgePrebuilt.wallet_lib
        .TWPrivateKeyGetPublicKeyEd25519(pk.cast())
        .cast();
  }

  static Pointer<Void> getPublicKeyNistEd25519Blake2b(Pointer<Void> pk) {
    return ffiBridgePrebuilt.wallet_lib
        .TWPrivateKeyGetPublicKeyEd25519Blake2b(pk.cast())
        .cast();
  }

  static Pointer<Void> getPublicKeyEd25519Cardano(Pointer<Void> pk) {
    return ffiBridgePrebuilt.wallet_lib
        .TWPrivateKeyGetPublicKeyEd25519Cardano(pk.cast())
        .cast();
  }

  static Pointer<Void> getPublicKeyCurve25519(Pointer<Void> pk) {
    return ffiBridgePrebuilt.wallet_lib
        .TWPrivateKeyGetPublicKeyCurve25519(pk.cast())
        .cast();
  }

  static Pointer<Void> getShareKey(
      Pointer<Void> pk, Pointer<Void> publicKey, int curve) {
    return ffiBridgePrebuilt.wallet_lib
        .TWPrivateKeyGetSharedKey(pk.cast(), publicKey.cast(), curve);
  }

  static Pointer<Void> sign(Pointer<Void> pk, Pointer<Void> digest, int curve) {
    return ffiBridgePrebuilt.wallet_lib
        .TWPrivateKeySign(pk.cast(), digest, curve);
  }

  static Pointer<Void> signAsDER(Pointer<Void> pk, Pointer<Void> digest) {
    return ffiBridgePrebuilt.wallet_lib
        .TWPrivateKeySignAsDER(pk.cast(), digest);
  }

  static Pointer<Void> signZilliqaSchnorr(
      Pointer<Void> pk, Pointer<Void> digest) {
    return ffiBridgePrebuilt.wallet_lib
        .TWPrivateKeySignZilliqaSchnorr(pk.cast(), digest);
  }
}
