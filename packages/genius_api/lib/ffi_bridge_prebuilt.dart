import 'dart:ffi';
import 'dart:io';
import 'package:genius_api/ffi/genius_api_ffi.dart';

class FFIBridgePrebuilt {

  static const String _libName = 'GeniusWallet';
  late NativeLibrary wallet_lib;

  FFIBridgePrebuilt() {

    final DynamicLibrary _dylib = () {
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        return DynamicLibrary.open('test/.build/ffi/lib$_libName.so');
      } else if (Platform.isAndroid) {
      return DynamicLibrary.open('lib$_libName.so');
      } else if (Platform.isMacOS || Platform.isIOS || Platform.isLinux || Platform.isWindows) {
      return DynamicLibrary.executable();
      }
      throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
    }();

    wallet_lib = NativeLibrary(_dylib);

  }
}
