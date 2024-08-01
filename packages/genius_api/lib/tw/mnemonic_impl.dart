import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/tw/string_util.dart';

class MnemonicImpl {
  static FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();
  static bool isValid(String mnemonic) {
    final value = StringUtil.toTWString(mnemonic);
    final bool result =
        ffiBridgePrebuilt.wallet_lib.TWMnemonicIsValid(value.cast());
    StringUtil.delete(value);

    return result;
  }

  static bool isValidWord(String word) {
    final value = StringUtil.toTWString(word);
    final bool result =
        ffiBridgePrebuilt.wallet_lib.TWMnemonicIsValidWord(value.cast());
    StringUtil.delete(value);

    return result;
  }

  static String suggest(String prefix) {
    final value = StringUtil.toTWString(prefix);
    final Pointer<Utf8> suggest =
        ffiBridgePrebuilt.wallet_lib.TWMnemonicSuggest(value.cast()).cast();

    StringUtil.delete(value);

    return StringUtil.toDartString(suggest);
  }
}
