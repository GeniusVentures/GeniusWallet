import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/tw/string_util.dart';

class CoinUtil {
  static FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();

  static String getSymbol(int coinType) {
    return StringUtil.toDartString(ffiBridgePrebuilt.wallet_lib
        .TWCoinTypeConfigurationGetSymbol(coinType)
        .cast());
  }
}
