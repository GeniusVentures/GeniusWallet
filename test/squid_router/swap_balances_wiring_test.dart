// What the two pickers are handed, and how many chain reads it cost.
//
// The pay side exists so a user cannot try to spend what they do not have, and
// until now it decided that from a fabricated list. These cases pin the three
// facts that replaced it: the native coin's balance comes from the figure the
// app already displays, an ERC-20's comes from the chain, and a catalogue entry
// the wallet does not hold is never read at all.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/squid_router/swap_field.dart';
import 'package:genius_wallet/squid_router/swap_screen.dart';
import 'package:genius_wallet/swap/swap_token.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

import '../swap/fake_swap_provider.dart';

const _native = '0x0000000000000000000000000000000000000000';
const _dai = '0x6B175474E89094C44Da98b954EedeAC495271d0F';
const _usdc = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';

/// A balance no rounding could have produced, so a figure taken from `Coin`'s
/// double instead of from the chain would be visible here.
final _daiRaw = BigInt.parse('1234567890123456789');

class _StubApi implements GeniusApi {
  final List<String> reads = [];

  @override
  Future<BigInt> rawBalanceOf({
    required String address,
    required String contractAddress,
    required String rpcUrl,
  }) async {
    reads.add(contractAddress);
    return _daiRaw;
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _CatalogueProvider extends FakeSwapProvider {
  const _CatalogueProvider();

  @override
  Future<List<SwapToken>> tokens(String chainId) async => const [
    SwapToken(
      chainId: '1',
      address: _native,
      name: 'Ethereum',
      symbol: 'ETH',
      decimals: 18,
    ),
    SwapToken(
      chainId: '1',
      address: _dai,
      name: 'Dai Stablecoin',
      symbol: 'DAI',
      decimals: 18,
    ),
    SwapToken(
      chainId: '1',
      address: _usdc,
      name: 'USD Coin',
      symbol: 'USDC',
      decimals: 6,
    ),
  ];
}

const _wallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Swap Wallet',
  currencySymbol: 'ETH',
  walletType: WalletType.mnemonic,
  balance: 0,
  address: '0xSWAPSWAPSWAPSWAPSWAPSWAPSWAPSWAPSWAPSWAP',
);

/// Holds DAI and nothing else. USDC is in the catalogue but not here, which is
/// what must keep it off the pay side AND off the RPC.
class _SeededCubit extends WalletDetailsCubit {
  _SeededCubit({
    required super.geniusApi,
    required super.networkTokensProvider,
  }) {
    emit(
      state.copyWith(
        selectedWallet: _wallet,
        selectedNetwork: const Network(
          name: 'Ethereum',
          symbol: 'ETH',
          chainId: 1,
          rpcUrl: 'https://rpc.invalid',
        ),
        selectedWalletBalance: '1.5',
        coins: const [Coin(symbol: 'DAI', address: _dai, balance: 1.23)],
      ),
    );
  }
}

Future<List<SwapField>> _mount(WidgetTester tester, _StubApi api) async {
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    BlocProvider<WalletDetailsCubit>(
      create: (_) => _SeededCubit(
        geniusApi: api,
        networkTokensProvider: NetworkTokensProvider(),
      ),
      child: MaterialApp(
        theme: ThemeData(extensions: [GWColors.dark()]),
        home: const SwapScreen(
          swapAvailable: true,
          provider: _CatalogueProvider(),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();

  return tester
      .widgetList<SwapField>(find.byType(SwapField))
      .toList(growable: false);
}

void main() {
  testWidgets('the pay side offers only what the wallet holds', (tester) async {
    final api = _StubApi();
    final fields = await _mount(tester, api);

    expect(fields, hasLength(2));
    expect(fields.first.label, 'You Pay');
    expect(fields.first.tokens.map((t) => t.symbol), ['ETH', 'DAI']);
  });

  testWidgets('the receive side keeps the full catalogue', (tester) async {
    final api = _StubApi();
    final fields = await _mount(tester, api);

    expect(fields.last.label, 'You Receive');
    expect(fields.last.tokens.map((t) => t.symbol), ['ETH', 'DAI', 'USDC']);
  });

  testWidgets('the native coin takes the figure the app already shows', (
    tester,
  ) async {
    final api = _StubApi();
    final fields = await _mount(tester, api);

    final eth = fields.last.tokens.firstWhere((t) => t.symbol == 'ETH');
    // 1.5 ETH, converted with the token's own decimals. No RPC path for it.
    expect(eth.rawBalance, BigInt.parse('1500000000000000000'));
    expect(api.reads, isNot(contains(_native)));
  });

  testWidgets('a held ERC-20 takes the exact integer from the chain', (
    tester,
  ) async {
    final api = _StubApi();
    final fields = await _mount(tester, api);

    final dai = fields.last.tokens.firstWhere((t) => t.symbol == 'DAI');
    expect(dai.rawBalance, _daiRaw);
    // Every digit survives: the picker caps at six, MAX does not.
    expect(dai.displayBalance, '1.234568');
    expect(dai.formattedBalance, '1.234567890123456789');
  });

  testWidgets('reads are bounded to the holdings, never the catalogue', (
    tester,
  ) async {
    final api = _StubApi();
    final fields = await _mount(tester, api);

    // One entry held, one read. A catalogue-wide read is dozens of round
    // trips per page load on a busy chain.
    expect(api.reads, [_dai]);

    final usdc = fields.last.tokens.firstWhere((t) => t.symbol == 'USDC');
    // Absent, not zero — nothing was asked, so nothing is known.
    expect(usdc.rawBalance, isNull);
  });
}
