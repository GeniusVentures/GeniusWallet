import 'dart:ffi';
import 'dart:io';
import 'package:genius_api/ffi/genius_api_ffi.dart';

typedef MyNativeType = Pointer<Void> Function(Pointer<Uint8>, Size);

class FFIBridgePrebuilt {
  //late Pointer<T> Function<T extends NativeType>(String symbolName) _lookup;
  //late double? Function() _libFunction;
  //late Pointer<Void> Function(Pointer<Uint8>, int) CreateTWBytes;
  late NativeLibrary wallet_lib;

  FFIBridgePrebuilt() {
    DynamicLibrary? dylib;
    if (Platform.isAndroid) {
      dylib = DynamicLibrary.open('libwalletWrapper.so');
    } else if (Platform.isIOS) {
      dylib = DynamicLibrary.process();
    } else if (Platform.environment.containsKey('FLUTTER_TEST')) {
      dylib = DynamicLibrary.open('test/${Platform.operatingSystem}/.build/libwalletWrapper.so');
    } else {
      dylib = null;
    }
    if (dylib != null) {
      wallet_lib = NativeLibrary(dylib);
      //_lookup = dylib.lookup;
      //_libFunction = dylib.lookupFunction<Double Function(), double Function()>(
      //    'TWDataCreateWithBytes');
      //CreateTWBytes = dylib
      //    .lookup<NativeFunction<Pointer<Void> Function(Pointer<Uint8>, Size)>>(
      //        'TWDataCreateWithBytes')
      //    .asFunction<Pointer<Void> Function(Pointer<Uint8>, int)>();
    } else {
      //CreateTWBytes = null as Pointer<Void> Function(Pointer<Uint8>, int);
    }
  }
//  late final _TWDataCreateWithBytesPtr = _lookup<
//      NativeFunction<
//          Pointer<Pointer<Void>> Function(
//              Pointer<Uint8>, Size)>>('TWDataCreateWithBytes');
//  late final _TWDataCreateWithBytes = _TWDataCreateWithBytesPtr.asFunction<
//      Pointer<Pointer<Void>> Function(Pointer<Uint8>, int)>();
//
//  Pointer<Pointer<Void>> TWDataCreateWithBytes(
//    Pointer<Uint8> bytes,
//    int size,
//  ) {
//    return _TWDataCreateWithBytes(
//      bytes,
//      size,
//    );
  double? getValueFromNative() 
  {
    return 12.0;
  }
  //Pointer<Void> TWDataCreateWithBytes(
  //  Pointer<Uint8> bytes,
  //  int size,
  //) {
  //  return CreateTWBytes(
  //    bytes,
  //    size,
  //  );
  //}
}
