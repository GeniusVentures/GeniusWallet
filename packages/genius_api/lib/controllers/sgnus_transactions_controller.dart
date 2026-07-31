import 'dart:async';
import 'package:genius_api/models/transaction.dart';
import 'package:rxdart/rxdart.dart';

class SGNUSTransactionsController {
  // The SDK feed's own set. Written only by [setTransactions], which
  // replaces it wholesale on every poll - that is real feed behaviour and
  // must not change.
  final Set<Transaction> _transactions = {};

  // Transactions added directly via [addTransaction] - the dev panel's
  // `Mock txns` button is its one caller today. These must survive every
  // SDK poll; only [clear] releases them.
  final Map<String, Transaction> _locallyAdded = {};

  final _controller = BehaviorSubject<List<Transaction>>();

  Stream<List<Transaction>> get stream => _controller.stream;

  SGNUSTransactionsController() {
    _controller.add([]);
  }

  void _emit() {
    // ponytail: `_locallyAdded.values` is a linear scan over the
    // locally-added set on every emit, fine at the dev panel's 11 fixtures
    // and not at thousands. `Transaction` has no value equality (no
    // `operator ==`, no `hashCode`, no Equatable - it is a plain Hive
    // model), so this map is keyed by `hash` to dedupe on insert instead.
    // The real upgrade path is value equality on `Transaction` itself,
    // which is out of scope here.
    final all = [..._transactions, ..._locallyAdded.values];
    _controller.add(List.unmodifiable(all.reversed.toList()));
  }

  void addTransaction(Transaction transaction) {
    _locallyAdded[transaction.hash] = transaction;
    _emit();
  }

  void setTransactions(List<Transaction> newTxs) {
    _transactions.clear();
    _transactions.addAll(newTxs);
    _emit();
  }

  void clear() {
    _transactions.clear();
    _locallyAdded.clear();
    _controller.add([]);
  }

  void dispose() {
    _controller.close();
  }
}
