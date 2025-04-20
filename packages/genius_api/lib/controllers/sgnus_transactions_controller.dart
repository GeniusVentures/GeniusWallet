import 'dart:async';
import 'package:genius_api/models/transaction.dart';
import 'package:rxdart/rxdart.dart';

class SGNUSTransactionsController {
  final Set<Transaction> _transactions = {};
  final _controller = BehaviorSubject<List<Transaction>>();
  Stream<List<Transaction>> get stream => _controller.stream;

  SGNUSTransactionsController() {
    _controller.add([]);
  }

  void addTransaction(Transaction transaction) {
    _transactions
        .add(transaction); // Will use freezed's equality implementation
    _controller
        .add(List.unmodifiable(_transactions.toList().reversed.toList()));
  }

  void addTransactions(List<Transaction> newTxs) {
    _transactions.addAll(newTxs);
    _controller
        .add(List.unmodifiable(_transactions.toList().reversed.toList()));
  }

  void clear() {
    _transactions.clear();
    _controller.add([]);
  }

  void dispose() {
    _controller.close();
  }
}
