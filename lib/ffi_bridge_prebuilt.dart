import 'dart:ffi';

class FFIBridgePrebuilt {
  late double Function() _libFunction;

  FFIBridgePrebuilt() {
    final dylib = DynamicLibrary.open('libnative.so');
    _libFunction = dylib.lookupFunction<Double Function(), double Function()>(
        'get_temperature');
  }

  double getValueFromNative() => _libFunction();
}
