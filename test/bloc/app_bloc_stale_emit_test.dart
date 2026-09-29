// A handler that awaits while building its emit must not overwrite a status
// another handler emitted meanwhile. The splash hung on exactly this: a slow
// link read put accountStatus back to loading after FetchAccount had loaded it.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/account.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:local_secure_storage/local_secure_storage.dart';

/// `implements`, not `extends`: the real constructor dlopens the native SDK.
class _SlowLinksApi implements GeniusApi {
  final links = Completer<Map<String, SDKAccountLink>>();
  final account = Completer<Account?>();

  @override
  Stream<SGNUSConnection> getSGNUSConnectionStream() => Stream.value(
    const SGNUSConnection(
      sgnusAddress: '',
      walletAddress: '',
      isConnected: false,
    ),
  );

  @override
  Future<Map<String, SDKAccountLink>> getSDKAccountLinks() => links.future;

  @override
  Future<Account?> getAccount() => account.future;

  @override
  List<String> getAvailableAccounts() => const [];

  @override
  String? getSelectedAccountAddress() => null;

  @override
  String? getStartAccountAddress() => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'a slow SDK refresh keeps the account status FetchAccount set',
    () async {
      final api = _SlowLinksApi();
      final bloc = AppBloc(
        api: api,
        transactionsCubit: TransactionsCubit(),
        walletDetailsCubit: WalletDetailsCubit(
          geniusApi: api,
          networkTokensProvider: NetworkTokensProvider(),
        ),
        networkProvider: NetworkProvider(),
      );
      addTearDown(bloc.close);

      bloc.add(FetchAccount());
      await bloc.stream.firstWhere((s) => s.accountStatus == AppStatus.loading);
      bloc.add(RefreshSDKAccounts());
      await Future<void>.delayed(Duration.zero);
      api.account.complete(null);
      await bloc.stream.firstWhere((s) => s.accountStatus == AppStatus.loaded);

      api.links.complete({});
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.accountStatus, AppStatus.loaded);
    },
  );
}
