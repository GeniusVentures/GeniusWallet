// Which network the coin list on WalletDetailsState was loaded for. Runs the
// Super Genius read, which needs no RPC once the token list is empty.
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class _FakeGeniusApi implements GeniusApi {
  @override
  String getSGNUSBalance() => '7';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _wallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletType: WalletType.sgnus,
  address: '0xCoinsNetworkWallet',
  balance: 0,
  currencySymbol: 'minions',
  walletName: 'Coins Network Wallet',
);

const _first = Network(name: 'Super Genius', symbol: 'gnus', chainId: 1);
const _second = Network(name: 'Super Genius Test', symbol: 'tgnus', chainId: 2);

void main() {
  test(
    'the coin list is claimed only for the network it was loaded on',
    () async {
      final cubit = WalletDetailsCubit(
        geniusApi: _FakeGeniusApi(),
        networkTokensProvider: NetworkTokensProvider(),
        initialState: const WalletDetailsState(
          selectedWallet: _wallet,
          selectedNetwork: _first,
        ),
      );
      addTearDown(cubit.close);

      await cubit.getCoins();
      expect(cubit.state.coinsNetwork, _first);

      cubit.selectNetwork(_second);
      // The switch has landed; the list on state is still the first network's.
      expect(cubit.state.selectedNetwork, _second);
      expect(cubit.state.coinsNetwork, _first);

      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.coinsNetwork, _second);
      expect(cubit.state.coins.single.symbol, 'TGNUS');
    },
  );
}
