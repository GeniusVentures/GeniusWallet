import 'package:genius_api/genius_api.dart';

abstract class WalletStorage {
  Future<void> saveWallet(Wallet wallet);

  Future<void> deleteWallet(String walletAddress);
}
