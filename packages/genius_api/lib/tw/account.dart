import 'dart:ffi';

import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/tw/string_util.dart';

class Account {
  late Pointer<Void> nativehandle;

  static FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();

  Account(Pointer<Void> pointer) {
    nativehandle = pointer;
  }

  static Account create(
    String address,
    TWCoinType coin,
    TWDerivation derivation,
    String derivationPath,
    String publicKey,
    String extendedPublicKey,
  ) {
    return Account(
      ffiBridgePrebuilt.twLib
          .TWAccountCreate(
            StringUtil.toTWString(address).cast(),
            coin,
            derivation,
            StringUtil.toTWString(derivationPath).cast(),
            StringUtil.toTWString(publicKey).cast(),
            StringUtil.toTWString(extendedPublicKey).cast(),
          )
          .cast(),
    );
  }

  String address() {
    return StringUtil.toDartString(
      ffiBridgePrebuilt.twLib.TWAccountAddress(nativehandle.cast()).cast(),
    );
  }

  TWCoinType coinType() {
    return ffiBridgePrebuilt.twLib.TWAccountCoin(nativehandle.cast());
  }

  TWDerivation derivation() {
    return ffiBridgePrebuilt.twLib.TWAccountDerivation(nativehandle.cast());
  }

  String derivationPath() {
    return StringUtil.toDartString(
      ffiBridgePrebuilt.twLib
          .TWAccountDerivationPath(nativehandle.cast())
          .cast(),
    );
  }

  String extendedPublicKey() {
    return StringUtil.toDartString(
      ffiBridgePrebuilt.twLib
          .TWAccountExtendedPublicKey(nativehandle.cast())
          .cast(),
    );
  }

  String publicKey() {
    return StringUtil.toDartString(
      ffiBridgePrebuilt.twLib.TWAccountPublicKey(nativehandle.cast()).cast(),
    );
  }
}
