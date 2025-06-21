import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/tw/string_util.dart';

class CoinUtil {
  static FFIBridgePrebuilt ffiBridgePrebuilt = FFIBridgePrebuilt();

  static String getSymbol(TWCoinType coinType) {
    return StringUtil.toDartString(ffiBridgePrebuilt.wallet_lib
        .TWCoinTypeConfigurationGetSymbol(coinType)
        .cast());
  }
}
