import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';

class FFIBridgePrebuilt {
  late double? Function() _libFunction;

  FFIBridgePrebuilt() {
    DynamicLibrary? dylib;
    if (Platform.isAndroid) {
      dylib = DynamicLibrary.open('libnative.so');
    } else if (Platform.isIOS) {
      dylib = DynamicLibrary.process();
    } else {
      dylib = DynamicLibrary.process();
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
