import 'package:genius_api/genius_api.dart';
import 'package:rxdart/rxdart.dart';

abstract class WalletStorage {
  /// [BehaviorSubject] used to stream the [List] of [Wallets]
  final walletsController = BehaviorSubject<List<Wallet>>.seeded([]);

  Stream<List<Wallet>> getWallets() => walletsController.asBroadcastStream();

  Future<void> saveWallet(Wallet wallet);

  Future<void> deleteWallet(String walletAddress);
}
