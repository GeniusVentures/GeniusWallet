import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/impl/tw_string_impl.dart';

class TWMnemonicImpl {
  static FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();
  static bool isValid(String mnemonic) {
    final value = TWStringImpl.toTWString(mnemonic);
    final bool result =
        ffiBridgePrebuilt.wallet_lib.TWMnemonicIsValid(value.cast());
    TWStringImpl.delete(value);

    return result;
  }

  static bool isValidWord(String word) {
    final value = TWStringImpl.toTWString(word);
    final bool result =
        ffiBridgePrebuilt.wallet_lib.TWMnemonicIsValidWord(value.cast());
    TWStringImpl.delete(value);

    return result;
  }

  static String suggest(String prefix) {
    final value = TWStringImpl.toTWString(prefix);
    final Pointer<Utf8> suggest =
        ffiBridgePrebuilt.wallet_lib.TWMnemonicSuggest(value.cast()).cast();

    TWStringImpl.delete(value);

    return TWStringImpl.toDartString(suggest);
  }
}
