import 'dart:ffi';
import 'dart:io';
import 'package:genius_api/ffi/genius_api_ffi.dart';

class FFIBridgePrebuilt {

  static const String _libName = 'GeniusWallet';
  late NativeLibrary wallet_lib;

  FFIBridgePrebuilt() {
    DynamicLibrary? dylib;
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      dylib = DynamicLibrary.open('test/${Platform.operatingSystem}/.build/lib$_libName.so');
    } else if (Platform.isAndroid || Platform.isLinux) {
      dylib = DynamicLibrary.open('lib$_libName.so');
    } else if (Platform.isMacOS || Platform.isIOS) {
      dylib = DynamicLibrary.process();
    } else if (Platform.isWindows) {
      dylib = DynamicLibrary.open('$_libName.dll');
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
