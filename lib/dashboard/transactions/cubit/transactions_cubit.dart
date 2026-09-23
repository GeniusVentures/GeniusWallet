import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/hive/services/transaction_storage_service.dart';

class TransactionsCubit extends Cubit<List<Transaction>> {
  final Set<Transaction> _transactions = {};

  TransactionsCubit({List<Transaction> initial = const []}) : super(initial) {
    _transactions.addAll(initial);
    emit(_sorted());
  }

  Future<void> loadInitial(String walletAddress) async {
    final txs = await const TransactionStorageService().getTransactions(
      walletAddress,
    );
    _transactions.addAll(txs);
    emit(_sorted());
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
