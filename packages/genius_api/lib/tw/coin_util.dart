import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/tw/string_util.dart';

class CoinUtil {
  static FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();

  static String getSymbol(int coinType) {
    return StringUtil.toDartString(ffiBridgePrebuilt.wallet_lib
        .TWCoinTypeConfigurationGetSymbol(coinType)
        .cast());
  }

  static String truncateToDecimals(String input, [int decimalPlaces = 5]) {
    int decimalIndex = input.indexOf('.');
    if (decimalIndex != -1 && input.length > decimalIndex + decimalPlaces + 1) {
      return input.substring(0, decimalIndex + decimalPlaces + 1);
    }
    return input;
  }
}
