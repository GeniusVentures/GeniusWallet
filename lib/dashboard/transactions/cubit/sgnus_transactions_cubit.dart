import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';

/// The SGNUS feed as bloc state, so widgets read it without touching the SDK.
class SgnusTransactionsCubit extends Cubit<List<Transaction>> {
  SgnusTransactionsCubit(Stream<List<Transaction>> feed) : super(const []) {
    _subscription = feed.listen(emit);
  }

  late final StreamSubscription<List<Transaction>> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
