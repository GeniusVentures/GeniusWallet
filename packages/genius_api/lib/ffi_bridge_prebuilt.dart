import 'dart:ffi';
import 'dart:io';

class FFIBridgePrebuilt {
  late double Function() _libFunction;

  FFIBridgePrebuilt() {
    final dylib = Platform.isAndroid
        ? DynamicLibrary.open('libnative.so')
        : DynamicLibrary.process();

    _libFunction = dylib.lookupFunction<Double Function(), double Function()>(
        'get_temperature');
  }

  double getValueFromNative() => _libFunction();
}
