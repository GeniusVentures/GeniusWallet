import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/hive/services/transaction_storage_service.dart';

class TransactionsCubit extends Cubit<List<Transaction>> {
  final Set<Transaction> _transactions = {};
  final TransactionStorageService _storage;

  TransactionsCubit({
    List<Transaction> initial = const [],
    TransactionStorageService storage = const TransactionStorageService(),
  }) : _storage = storage,
       super(initial) {
    _transactions.addAll(initial);
    emit(_sorted());
  }

  /// The wallet whose history this cubit holds, or is loading.
  String? _walletAddress;

  /// Loads [walletAddress]'s stored history. Switching wallets drops the old
  /// rows at once, and a read that a newer switch superseded is discarded.
  Future<void> loadInitial(String walletAddress) async {
    if (walletAddress != _walletAddress) {
      // The first load merges, as rows can arrive before any wallet is known.
      if (_walletAddress != null) {
        _transactions.clear();
        emit([]);
      }
      _walletAddress = walletAddress;
    }
    final txs = await _storage.getTransactions(walletAddress);
    if (walletAddress != _walletAddress) {
      return;
    }
    _transactions.addAll(txs);
    emit(_sorted());
  }

  /// [loadInitial], skipped when [walletAddress] is already the one shown.
  Future<void> showWallet(String walletAddress) async {
    if (walletAddress == _walletAddress) {
      return;
    }
    await loadInitial(walletAddress);
  }

  void addTransaction(Transaction tx) {
    _transactions.add(tx);
    emit(_sorted());
  }

  /// Swaps the row sharing [tx]'s hash for [tx] -- a pending row settling.
  void replaceTransaction(Transaction tx) {
    _transactions.removeWhere((t) => t.hash == tx.hash);
    _transactions.add(tx);
    emit(_sorted());
  }

  void addTransactions(List<Transaction> txs) {
    _transactions.addAll(txs);
    emit(_sorted());
  }

  void clear() {
    _transactions.clear();
    emit([]);
  }

  List<Transaction> _sorted() {
    final list = List<Transaction>.from(_transactions);
    list.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
    return list;
  }
}
