import 'dart:ffi';
import 'dart:io';

class FFIBridgePrebuilt {
  late double? Function() _libFunction;

  FFIBridgePrebuilt() {
    DynamicLibrary? dylib;
    if (Platform.isAndroid) {
      dylib = DynamicLibrary.open('libnative.so');
    } else if (Platform.isIOS) {
      dylib = DynamicLibrary.process();
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
