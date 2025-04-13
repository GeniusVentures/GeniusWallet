import 'dart:ffi';
import 'dart:io';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:flutter/material.dart';

class FFIBridgePrebuilt {
  static const String _libName = 'GeniusWallet';
  late NativeLibrary wallet_lib;

  FFIBridgePrebuilt() {
    final DynamicLibrary? _dylib = () {
      if (Platform.isAndroid) {
        return loadGeniusWalletLibrary();
      } else if (Platform.isIOS) {
        return DynamicLibrary.open('GeniusWallet.framework/GeniusWallet');
      } else if (Platform.isMacOS) {
        return DynamicLibrary.open('GeniusWallet.framework/GeniusWallet');
      }
      return DynamicLibrary.executable();
    }();

    if (_dylib == null) {
      return;
    }

    wallet_lib = NativeLibrary(_dylib);
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
