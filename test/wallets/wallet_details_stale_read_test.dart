// A holdings read overtaken by a newer one must not land. A local RPC server
// holds the first read open until the switch has finished.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class _FakeGeniusApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _wallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletType: WalletType.privateKey,
  address: '0x1111111111111111111111111111111111111111',
  balance: 0,
  currencySymbol: 'ETH',
  walletName: 'Stale Read Wallet',
);

const _node = Network(name: 'Super Genius', symbol: 'gnus', chainId: 2);

void main() {
  test(
    'a read that lands after a switch does not replace the newer one',
    () async {
      final release = Completer<void>();
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      server.listen((request) async {
        final body = jsonDecode(await utf8.decodeStream(request)) as Map;
        await release.future;
        request.response
          ..headers.contentType = ContentType.json
          ..write(
            jsonEncode({'jsonrpc': '2.0', 'id': body['id'], 'result': '0x1'}),
          );
        await request.response.close();
      });
      final rpc = Network(
        name: 'Ethereum',
        symbol: 'eth',
        chainId: 1,
        rpcUrl: 'http://127.0.0.1:${server.port}',
      );

      final cubit = WalletDetailsCubit(
        geniusApi: _FakeGeniusApi(),
        networkTokensProvider: NetworkTokensProvider(),
        initialState: WalletDetailsState(
          selectedWallet: _wallet,
          selectedNetwork: rpc,
        ),
      );
      addTearDown(cubit.close);
      cubit.appStateChanged(const AppState(selectedSDKAccount: '0xnode'));

      final stale = cubit.getCoins();
      // The node has no account for this wallet, so this read is unreadable.
      cubit.selectNetwork(_node);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.balanceUnreadable, isTrue);
      expect(cubit.state.coinsNetwork, _node);

      release.complete();
      await stale;

      expect(cubit.state.balanceUnreadable, isTrue);
      expect(cubit.state.coinsNetwork, _node);
      expect(cubit.state.coins, isEmpty);
    },
  );
}
