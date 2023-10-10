import 'dart:ffi';
import 'dart:io';
import 'package:genius_api/ffi/genius_api_ffi.dart';

class FFIBridgePrebuilt {

  late NativeLibrary wallet_lib;

  FFIBridgePrebuilt() {
    DynamicLibrary? dylib;
    if (Platform.isAndroid) {
      dylib = DynamicLibrary.open('libGeniusWallet.so');
    } else if (Platform.isIOS) {
      dylib = DynamicLibrary.process();
    } else if (Platform.environment.containsKey('FLUTTER_TEST')) {
      dylib = DynamicLibrary.open('test/${Platform.operatingSystem}/.build/libGeniusWallet.so');
    } else {
      dylib = null;
    }
    if (dylib != null) {
      wallet_lib = NativeLibrary(dylib);

    } else {
    }
  }
  double? getValueFromNative() 
  {
    return 12.0;
  }

}
