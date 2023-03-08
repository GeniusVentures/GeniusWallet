import 'dart:ffi';
import 'dart:io';
import 'package:path/path.dart' as path;

class FFIBridgePrebuilt {
  late double? Function() _libFunction;

  FFIBridgePrebuilt() {
    DynamicLibrary? dylib;
    if (Platform.isAndroid) {
      dylib = DynamicLibrary.open('libnative.so');
    } else if (Platform.isIOS) {
      dylib = DynamicLibrary.process();
    } else if (Platform.isWindows) {
      var libraryPath = path.join(Directory.current.path, 'hello.dll');
      dylib = DynamicLibrary.open(libraryPath);
    } else if (Platform.isLinux) {
      var libraryPath = path.join(Directory.current.path, 'libhello.so');
      dylib = DynamicLibrary.open(libraryPath);
    } else {
      dylib = null;
    }
    if (dylib != null) {
      _libFunction = dylib.lookupFunction<Double Function(), double Function()>(
          'get_temperature');
    } else {
      _libFunction = () => null;
    }
  }

  double? getValueFromNative() => _libFunction();
}
