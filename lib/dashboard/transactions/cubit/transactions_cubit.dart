import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/hive/services/transaction_storage_service.dart';

class TransactionsCubit extends Cubit<List<Transaction>> {
  final Set<Transaction> _transactions = {};

  TransactionsCubit({List<Transaction> initial = const []})
      : super(_sortInitial(initial)) {
    _transactions.addAll(initial);
  }

  // Sort the seed list up front (passed to super) rather than emitting from the
  // constructor. A ctor emit fires synchronously and can land mid-frame when
  // this cubit is created during the first build (e.g. the router redirect
  // reads AppBloc, which creates this) -> "!_dirty" red-screen on cold start.
  static List<Transaction> _sortInitial(List<Transaction> initial) {
    final list = initial.toSet().toList();
    list.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
    return list;
  }

  Future<void> loadInitial(String walletAddress) async {
    final txs =
        await TransactionStorageService().getTransactions(walletAddress);
    _transactions.addAll(txs);
    emit(_sorted());
  }

  void addTransaction(Transaction tx) {
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
