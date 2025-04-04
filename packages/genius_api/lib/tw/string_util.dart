import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:genius_api/ffi_bridge_prebuilt.dart';

class StringUtil {
  static FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();

  /// It must be deleted at the end.
  static Pointer<Utf8> toTWString(String value) {
    return ffiBridgePrebuilt.wallet_lib
        .TWStringCreateWithUTF8Bytes(value.toNativeUtf8())
        .cast();
  }

  static int size(Pointer<Utf8> string) {
    return ffiBridgePrebuilt.wallet_lib.TWStringSize(string.cast());
  }

  static String toDartString(Pointer<Utf8> value) {
    return ffiBridgePrebuilt.wallet_lib
        .TWStringUTF8Bytes(value.cast())
        .cast<Utf8>()
        .toDartString();
  }

  static void delete(Pointer<Utf8> string) {
    ffiBridgePrebuilt.wallet_lib.TWStringDelete(string.cast());
  }

  static bool twStringEqual(Pointer<Utf8> lhs, Pointer<Utf8> rhs) {
    return ffiBridgePrebuilt.wallet_lib.TWStringEqual(lhs.cast(), rhs.cast());
  }
}
