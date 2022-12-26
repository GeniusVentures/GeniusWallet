import 'dart:ffi';
import 'dart:io';

typedef TemperatureFunction = Double Function();
typedef TemperatureFunctionDart = double Function();
// TODO: Add new typedef declarations here

// TODO: Add ThreeDayForecast here

class FFIBridge {
  late TemperatureFunctionDart _getTemperature;

  FFIBridge() {
    final dl = Platform.isAndroid
        ? DynamicLibrary.open('libnative.so')
        : DynamicLibrary.process();

    _getTemperature =
        dl.lookupFunction<TemperatureFunction, TemperatureFunctionDart>(
            'get_temperature');
  }
  double getValueFromNative() => _getTemperature();
}
