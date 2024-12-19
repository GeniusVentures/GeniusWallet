import 'dart:ffi';
import 'dart:io';
import 'package:genius_api/ffi/genius_api_ffi.dart';

class FFIBridgePrebuilt {

  static const String _libName = 'GeniusWallet';
  late NativeLibrary wallet_lib;

  FFIBridgePrebuilt() {

    final DynamicLibrary _dylib = () {
      if (Platform.isAndroid) {
        return DynamicLibrary.open('libGeniusWallet.so');
      } else if (Platform.isIOS) {
        return DynamicLibrary.open('GeniusWallet.framework/GeniusWallet');
      } else if (Platform.isMacOS) {
        return DynamicLibrary.open('GeniusWallet.framework/GeniusWallet');
      }
      throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
    }();



    wallet_lib = NativeLibrary(_dylib);

  }
}
