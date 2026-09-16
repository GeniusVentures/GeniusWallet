import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/squid_router/squid_client.dart';
import 'package:genius_wallet/squid_router/swap_screen.dart';
import 'package:genius_wallet/swap/swap_provider.dart';
import 'package:genius_wallet/swap/swap_quote.dart';
import 'package:genius_wallet/swap/swap_token.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:squidrouter/squidrouter.dart';

Map<String, dynamic> _wire(RouteRequest request) =>
    standardSerializers.serializeWith(RouteRequest.serializer, request)
        as Map<String, dynamic>;

/// `WalletDetailsCubit` needs a `GeniusApi` this screen never touches, so the
/// stand-in throws loudly rather than returning a silent null.
class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

/// Answers the catalogue with nothing, so the fetch is ENTERED and finishes
/// without a network. The cases below read the first frame, not the list.
class _EmptyCatalogueProvider implements SwapProvider {
  const _EmptyCatalogueProvider();

  @override
  Future<List<SwapToken>> tokens(String chainId) async => const [];

  @override
  Future<SwapQuote> quote(SwapQuoteRequest request) =>
      throw UnimplementedError('no route is fetched in these cases');
}

/// A network is seeded because the screen filters the catalogue by chain id
/// and has nothing to fetch without one.
class _SeededWalletDetailsCubit extends WalletDetailsCubit {
  _SeededWalletDetailsCubit({
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
        ),
      ),
    );
  }
}

const _wallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Swap Wallet',
  currencySymbol: 'ETH',
  walletType: WalletType.mnemonic,
  balance: 0,
  address: '0xSWAPSWAPSWAPSWAPSWAPSWAPSWAPSWAPSWAPSWAP',
);

Widget _host(Widget child) => BlocProvider<WalletDetailsCubit>(
  create: (_) => _SeededWalletDetailsCubit(
    geniusApi: _UnusedApi(),
    networkTokensProvider: NetworkTokensProvider(),
  ),
  child: MaterialApp(
    theme: ThemeData(extensions: [GWColors.dark()]),
    home: child,
  ),
);

void main() {
  group('the request Squid is sent', () {
    test('a quoteOnly route carries every field the API requires', () {
      final json = _wire(
        RouteRequest(
          (b) => b
            ..fromChain = '8453'
            ..fromToken = '0x0000000000000000000000000000000000000000'
            ..fromAmount = '1000000000000000'
            ..toChain = '137'
            ..toToken = '0x2791bca1f2de4661ed88a30c99a7a9449aa84174'
            ..quoteOnly = true,
        ),
      );

      expect(json['fromChain'], '8453');
      expect(json['fromToken'], '0x0000000000000000000000000000000000000000');
      expect(json['fromAmount'], '1000000000000000');
      expect(json['toChain'], '137');
      expect(json['toToken'], '0x2791bca1f2de4661ed88a30c99a7a9449aa84174');
      expect(json['quoteOnly'], isTrue);
    });

    test(
      'quoteOnly is absent unless asked for, so a route is never a quote',
      () {
        final json = _wire(
          RouteRequest(
            (b) => b
              ..fromChain = '8453'
              ..fromToken = '0x0000000000000000000000000000000000000000'
              ..fromAmount = '1'
              ..toChain = '137'
              ..toToken = '0x2791bca1f2de4661ed88a30c99a7a9449aa84174',
          ),
        );

        expect(json.containsKey('quoteOnly'), isFalse);
      },
    );
  });

  group('the client app code reaches', () {
    test('points at the v2 host', () {
      expect(Squidrouter.basePath, 'https://v2.api.squidrouter.com');
    });

    test('resolves the two calls a swap needs, and is built once', () {
      final api = squidApi();

      expect(api.getRoute, isA<Function>());
      expect(api.getStatus, isA<Function>());
      expect(identical(api, squidApi()), isTrue);
    });
  });

  group('availability', () {
    test('an unconfigured build reports itself unavailable', () {
      // No --dart-define under `flutter test`, so this is the default build.
      expect(kSquidIntegratorId, isEmpty);
      expect(squidConfigured, isFalse);
    });
  });

  group('an unconfigured build is honest about it', () {
    // `isLoading` starts true and is cleared ONLY by the token fetch, so a
    // first frame with no `Loading` is proof the fetch was never entered.
    testWidgets('renders the CTA as unavailable and reaches for nothing', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_host(const SwapScreen(swapAvailable: false)));

      expect(find.byType(Loading), findsNothing);
      expect(find.text('Swap unavailable'), findsOneWidget);
      // The tappable rung is a GWButton. Its absence is what "disabled" means
      // here — there is nothing to press, not merely a null callback.
      expect(find.byType(GWButton), findsNothing);
    });

    testWidgets('an available build does reach for tokens', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _host(
          const SwapScreen(
            swapAvailable: true,
            provider: _EmptyCatalogueProvider(),
          ),
        ),
      );

      expect(find.byType(Loading), findsOneWidget);

      await tester.pump();
      await tester.pump();

      expect(find.text('Swap unavailable'), findsNothing);
    });
  });
}
