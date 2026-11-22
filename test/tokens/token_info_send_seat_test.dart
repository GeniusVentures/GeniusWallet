// The seat a token page hands /send must come from the coin that page is
// showing, not from market data the page may not have (a private-net coin
// has none) and not from the wallet's whatever-was-selected coin.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/tokens/token_info_args.dart';
import 'package:genius_wallet/tokens/token_info_screen.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

const _superGenius = Network(
  name: 'Super Genius',
  symbol: 'gnus',
  chainId: 963,
  rpcUrl: 'https://rpc.invalid',
);

// A Super Genius holding: no contract address - the ticker is all it has.
const _nativeGnus = Coin(
  name: 'Super Genius',
  symbol: 'GNUS',
  networkSymbol: 'gnus',
  balance: 1000,
);

void main() {
  testWidgets('a wallet token page with no market data pushes /send with a '
      'symbol that seats that coin', (tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    Map<String, dynamic>? sendExtra;
    final walletCubit = WalletDetailsCubit(
      initialState: const WalletDetailsState(
        selectedWallet: Wallet(
          coinType: TWCoinType.TWCoinTypeEthereum,
          walletName: 'Seat Wallet',
          currencySymbol: 'GNUS',
          walletType: WalletType.mnemonic,
          balance: 1000,
          address: '0xSEATSEATSEATSEATSEATSEATSEATSEATSEATSEAT',
        ),
        selectedNetwork: _superGenius,
        coins: [_nativeGnus],
        coinsNetwork: _superGenius,
        coinsStatus: WalletStatus.successful,
      ),
      geniusApi: _UnusedApi(),
      networkTokensProvider: NetworkTokensProvider(),
    );
    addTearDown(walletCubit.close);

    final router = GoRouter(
      initialLocation: '/token-info',
      routes: [
        GoRoute(
          path: '/token-info',
          builder: (context, state) => BlocProvider<WalletDetailsCubit>.value(
            value: walletCubit,
            child: TokenInfoScreen(
              walletDetailsCubit: walletCubit,
              args: const TokenInfoArgs(
                walletCoin: _nativeGnus,
                network: 'gnus',
              ),
              resolveMarketData: (_) async => const {},
            ),
          ),
        ),
        GoRoute(
          path: '/send',
          builder: (_, state) {
            sendExtra = state.extra as Map<String, dynamic>?;
            return const SizedBox.shrink();
          },
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: ThemeData(extensions: [GWColors.dark()]),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(GWButton, 'Send'));
    await tester.pumpAndSettle();

    expect(sendExtra, isNotNull);
    // The page's own coin: native GNUS seats by its ticker when it has no
    // contract address to match.
    expect(sendExtra!['symbol'], 'GNUS');
    expect(sendExtra!['address'], isNull);
  });
}
