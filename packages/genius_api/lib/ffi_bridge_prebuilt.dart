import 'dart:ffi';
import 'dart:io';
import 'package:genius_api/ffi/genius_api_ffi.dart';

class FFIBridgePrebuilt {

  static const String _libName = 'GeniusWallet';
  late NativeLibrary wallet_lib;

  FFIBridgePrebuilt() {

    final DynamicLibrary _dylib = () {
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        return DynamicLibrary.open('test/${Platform.operatingSystem}/.build/lib$_libName.so');
      } else if (Platform.isAndroid || Platform.isLinux) {
      return DynamicLibrary.open('lib$_libName.so');
      } else if (Platform.isMacOS || Platform.isIOS) {
      return DynamicLibrary.process();
      } else if (Platform.isWindows) {
      return DynamicLibrary.open('$_libName.dll');
      }
      throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
    }();

    wallet_lib = NativeLibrary(_dylib);

  }
}
