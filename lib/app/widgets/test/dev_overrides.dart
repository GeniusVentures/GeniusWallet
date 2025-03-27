import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_api/types/wallet_type.dart';

const walletPK = String.fromEnvironment('WALLET_PK', defaultValue: '');

bool isWalletPKBypass() {
  return walletPK.isNotEmpty;
}

void byPassSGNUSConnecton(geniusApi) {
  if (!isWalletPKBypass()) {
    return;
  }

  print('\x1B[37m** Manually skipping SGNUS connection\x1B[0m');

  geniusApi.getSGNUSController().updateConnection(const SGNUSConnection(
      sgnusAddress: "0x67890", walletAddress: "0x12345", isConnected: true));
}

void byPassWalletCreation(localWalletStorage) {
  if (!isWalletPKBypass()) {
    return;
  }

  print('\x1B[37m** Manually importing wallet from variable\x1B[0m');

  localWalletStorage.addWalletToController(const Wallet(
      walletName: 'Bypass Wallet',
      currencySymbol: 'eth',
      coinType: TWCoinType.TWCoinTypeEthereum,
      balance: 0,
      address: '0x6084a30B8CFe3fd27b0672b8fE740B9a8541403e',
      walletType: WalletType.privateKey,
      transactions: []));
}
