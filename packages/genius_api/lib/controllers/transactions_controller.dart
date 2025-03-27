import 'dart:async';
import 'package:genius_api/models/transaction.dart';
import 'package:rxdart/rxdart.dart';

class TransactionsController {
  final List<Transaction> _transactions = [];

  final _controller = BehaviorSubject<List<Transaction>>();

  Stream<List<Transaction>> get stream => _controller.stream;

  TransactionsController() {
    _controller.add([]);
  }

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    _controller.add(List.unmodifiable(_transactions.reversed.toList()));
  }

  void addTransactions(List<Transaction> newTxs) {
    _transactions.addAll(newTxs);
    _controller.add(List.unmodifiable(_transactions.reversed.toList()));
  }

  void clear() {
    _transactions.clear();
    _controller.add([]);
  }

  void dispose() {
    _controller.close();
  }
}
