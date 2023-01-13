import 'dart:ffi';
import 'dart:io';

typedef TemperatureFunction = Double Function();
typedef TemperatureFunctionDart = double Function();

class FFIBridge {
  late TemperatureFunctionDart? _getTemperature;

  FFIBridge() {
    DynamicLibrary? dl;
    if (Platform.isAndroid) {
      dl = DynamicLibrary.open('libnative.so');
    } else if (Platform.isIOS) {
      dl = DynamicLibrary.process();
    } else {
      dl = null;
      // TO DO, Add some code for MacOS version
    }
    if (dl != null) {
      _getTemperature =
          dl.lookupFunction<TemperatureFunction, TemperatureFunctionDart>(
              'get_temperature');
    } else {
      _getTemperature = null;
    }
  }
  double? getValueFromNative() => _getTemperature!();
}
