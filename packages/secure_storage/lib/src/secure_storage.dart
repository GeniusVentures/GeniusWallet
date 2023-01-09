import 'package:genius_api/genius_api.dart';
import 'package:rxdart/rxdart.dart';

abstract class SecureStorage {
  /// [BehaviorSubject] used to stream the [List] of {}
  final walletsController = BehaviorSubject<List<Wallet>>.seeded([]);

  Stream<List<Wallet>> getWallets() => walletsController.asBroadcastStream();

  Future<void> saveWallet(Wallet wallet);

  Future<void> deleteWallet(String walletAddress);

  Future<void> storeUserPin(String pin);

  Future<bool> verifyUserPin(String pin);

  Future<bool> pinExists();
}
