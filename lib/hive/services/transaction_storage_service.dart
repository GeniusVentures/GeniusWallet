import 'package:genius_api/genius_api.dart';
import 'package:hive/hive.dart';

/// Usage
// final txService = TransactionStorageService();

// Save a transaction
// await txService.addTransaction('0x123...', myTransaction);

// Retrieve all
// final transactions = await txService.getTransactions('0x123...');

// Delete one
// await txService.removeTransaction('0x123...', '0xhash');

// Clear all
// await txService.clearWallet('0x123...');

class TransactionStorageService {
  Future<Box<Transaction>> _getWalletBox(String walletAddress) async {
    final boxName = 'transactions_$walletAddress';
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<Transaction>(boxName);
    }
    return Hive.box<Transaction>(boxName);
  }

  Future<void> addTransaction(String walletAddress, Transaction tx) async {
    final box = await _getWalletBox(walletAddress);
    await box.put(tx.hash, tx); // use hash as unique key
  }

  Future<List<Transaction>> getTransactions(String walletAddress) async {
    final box = await _getWalletBox(walletAddress);
    return box.values.toList();
  }

  Future<void> removeTransaction(String walletAddress, String txHash) async {
    final box = await _getWalletBox(walletAddress);
    await box.delete(txHash);
  }

  Future<void> clearWallet(String walletAddress) async {
    final box = await _getWalletBox(walletAddress);
    await box.clear();
  }

  Future<void> closeWalletBox(String walletAddress) async {
    final boxName = 'transactions_$walletAddress';
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box<Transaction>(boxName).close();
    }
  }
}
