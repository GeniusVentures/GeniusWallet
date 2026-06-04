import 'dart:ffi';
import 'dart:io';
import 'package:genius_api/ffi/genius_api_ffi.dart' as gns;
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart' as tw;
import 'package:flutter/material.dart';

class FFIBridgePrebuilt {
  late tw.NativeLibrary tw_lib;
  late gns.NativeLibrary sgns_lib;

  FFIBridgePrebuilt() {
    final dylib = loadGeniusSDKLibrary();
    if (dylib == null) {
      return;
    }

    tw_lib = tw.NativeLibrary(dylib);
    sgns_lib = gns.NativeLibrary(dylib);
  }
}

/// Loads the Genius SDK shared library with platform-specific detection.
DynamicLibrary? loadGeniusSDKLibrary() {
  if (Platform.isAndroid) {
    try {
      return DynamicLibrary.open('libGeniusWallet.so');
    } catch (e) {
      debugPrint("❌ Error loading library: $e");
      return null;
    }
  }
  if (Platform.isIOS || Platform.isMacOS) {
    return DynamicLibrary.open('GeniusWallet.framework/GeniusWallet');
  }
  return DynamicLibrary.executable();
}
