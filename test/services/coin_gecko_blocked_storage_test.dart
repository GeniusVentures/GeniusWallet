import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
import 'package:local_secure_storage/local_secure_storage.dart';

class _BlockedStoreApi implements GeniusApi {
  @override
  Future<void> updateAccountFetchDate() =>
      Future.error(const SecureStorageWriteError());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('a background balance save on a blocked store raises nothing', () async {
    final uncaught = <Object>[];

    await runZonedGuarded(() async {
      await fetchCoinPricesSum(
        coinIds: const [],
        coinBalances: const [],
        geniusApi: _BlockedStoreApi(),
      );
      await Future<void>.delayed(Duration.zero);
    }, (error, _) => uncaught.add(error));

    expect(uncaught, isEmpty);
  });
}
