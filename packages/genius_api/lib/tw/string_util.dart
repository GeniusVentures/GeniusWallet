import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:genius_api/ffi_bridge_prebuilt.dart';

class StringUtil {
  static FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();

  /// It must be deleted at the end. The UTF-8 staging copy is wiped and freed
  /// here, since Trust Wallet copies it: callers pass seed phrases through.
  static Pointer<Utf8> toTWString(String value) {
    final utf8 = value.toNativeUtf8();
    try {
      return ffiBridgePrebuilt.twLib
          .TWStringCreateWithUTF8Bytes(utf8.cast())
          .cast();
    } finally {
      utf8.cast<Uint8>().asTypedList(utf8.length).fillRange(0, utf8.length, 0);
      malloc.free(utf8);
    }
  }

  static int size(Pointer<Utf8> string) {
    return ffiBridgePrebuilt.twLib.TWStringSize(string.cast());
  }

  static String toDartString(Pointer<Utf8> value) {
    return ffiBridgePrebuilt.twLib
        .TWStringUTF8Bytes(value.cast())
        .cast<Utf8>()
        .toDartString();
  }

  static void delete(Pointer<Utf8> string) {
    ffiBridgePrebuilt.twLib.TWStringDelete(string.cast());
  }

  static bool twStringEqual(Pointer<Utf8> lhs, Pointer<Utf8> rhs) {
    return ffiBridgePrebuilt.twLib.TWStringEqual(lhs.cast(), rhs.cast());
  }
}
