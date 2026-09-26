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

  /// Puts [tx] in place of any row sharing its hash, but only while
  /// [walletAddress] -- the wallet the operation started from -- is shown.
  /// Callers store the row for that wallet themselves, so none is lost.
  void replaceTransaction(String walletAddress, Transaction tx) {
    final shown = _walletAddress;
    if (shown != null && shown.toLowerCase() != walletAddress.toLowerCase()) {
      return;
    }
    _transactions.removeWhere((t) => t.hash == tx.hash);
    _transactions.add(tx);
    emit(_sorted());
  }

  /// Dev fixture rows for whatever is on screen; they are never stored.
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
