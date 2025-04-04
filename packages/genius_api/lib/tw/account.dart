import 'dart:ffi';

import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/tw/string_util.dart';

class Account {
  late Pointer<Void> nativehandle;

  static FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();

  Account(Pointer<Void> pointer) {
    nativehandle = pointer;
  }

  static Account create(String address, int coin, int derivation,
      String derivationPath, String publicKey, String extendedPublicKey) {
    return Account(ffiBridgePrebuilt.wallet_lib
        .TWAccountCreate(
            StringUtil.toTWString(address).cast(),
            coin,
            derivation,
            StringUtil.toTWString(derivationPath).cast(),
            StringUtil.toTWString(publicKey).cast(),
            StringUtil.toTWString(extendedPublicKey).cast())
        .cast());
  }

  String address() {
    return StringUtil.toDartString(ffiBridgePrebuilt.wallet_lib
        .TWAccountAddress(nativehandle.cast())
        .cast());
  }

  int coinType() {
    return ffiBridgePrebuilt.wallet_lib.TWAccountCoin(nativehandle.cast());
  }

  int derivation() {
    return ffiBridgePrebuilt.wallet_lib
        .TWAccountDerivation(nativehandle.cast());
  }

  String derivationPath() {
    return StringUtil.toDartString(ffiBridgePrebuilt.wallet_lib
        .TWAccountDerivationPath(nativehandle.cast())
        .cast());
  }

  String extendedPublicKey() {
    return StringUtil.toDartString(ffiBridgePrebuilt.wallet_lib
        .TWAccountExtendedPublicKey(nativehandle.cast())
        .cast());
  }

  String publicKey() {
    return StringUtil.toDartString(ffiBridgePrebuilt.wallet_lib
        .TWAccountPublicKey(nativehandle.cast())
        .cast());
  }
}
