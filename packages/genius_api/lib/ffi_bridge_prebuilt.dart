import 'dart:ffi';
import 'dart:io';
import 'package:genius_api/ffi/genius_api_ffi.dart' as gns;
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart' as tw;
import 'package:flutter/material.dart';

class FFIBridgePrebuilt {
  static const String _libName = 'GeniusWallet';
  late tw.NativeLibrary wallet_lib;
  late gns.NativeLibrary gns_lib;

  FFIBridgePrebuilt() {
    final DynamicLibrary? dylib = () {
      if (Platform.isAndroid) {
        return loadGeniusWalletLibrary();
      } else if (Platform.isIOS) {
        return DynamicLibrary.open('GeniusWallet.framework/GeniusWallet');
      } else if (Platform.isMacOS) {
        return DynamicLibrary.open('GeniusWallet.framework/GeniusWallet');
      }
      return DynamicLibrary.executable();
    }();

    if (dylib == null) {
      return;
    }

    wallet_lib = tw.NativeLibrary(_dylib);
  }
}

DynamicLibrary? loadGeniusWalletLibrary() {
  try {
    // Attempt to load the shared library
    final library = DynamicLibrary.open('libGeniusWallet.so');
    return library;
  } catch (e) {
    debugPrint("❌ Error loading library: $e");
    return null; // Return null to handle errors gracefully
  }
}
