import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_gate_cubit.dart';
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

const _amoy = Network(
  name: 'Polygon Amoy',
  symbol: 'matic',
  chainId: 80002,
  rpcUrl: 'https://rpc.invalid',
);

const _walletAddress = '0xAbCd567890123456789012345678901234567890';
const _otherAddress = '0x1111111111111111111111111111111111111111';
final _sdkAccount = '0x${'a' * 128}';

const _wallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Test Wallet',
  currencySymbol: 'MATIC',
  walletType: WalletType.mnemonic,
  balance: 0,
  address: _walletAddress,
);

const _gnus = Coin(symbol: 'GNUS', address: '0xabc', balance: 10);

// What the wallet had selected before the tap: a GNUS entry that is not the
// contract coin, so the test can see the tap replace it.
const _staleSelection = Coin(symbol: 'GNUS', balance: 0);

AppState _appState({String linkedWallet = _walletAddress, String? switching}) =>
    AppState(
      selectedSDKAccount: _sdkAccount,
      switchingSDKAccount: switching,
      sdkAccountLinks: {
        _sdkAccount.toLowerCase(): (
          walletAddress: linkedWallet.toLowerCase(),
          walletName: 'Linked',
        ),
      },
    );

class _Host {
  _Host(this.app) {
    wallet = WalletDetailsCubit(
      initialState: const WalletDetailsState(
        selectedWallet: _wallet,
        selectedNetwork: _amoy,
        selectedCoin: _staleSelection,
        coins: [_gnus],
        coinsNetwork: _amoy,
        coinsStatus: WalletStatus.successful,
      ),
      geniusApi: _UnusedApi(),
      networkTokensProvider: NetworkTokensProvider(),
    );
    gate = BridgeGateCubit(
      readAppState: () => app,
      appStates: appStream.stream,
      walletDetails: wallet,
    );
  }

  AppState app;
  final appStream = StreamController<AppState>.broadcast();
  late final WalletDetailsCubit wallet;
  late final BridgeGateCubit gate;
  final bridgePushes = <String>[];

  Future<void> dispose() async {
    await gate.close();
    await wallet.close();
    await appStream.close();
  }

  Widget build({GWColors? colors}) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => TokenInfoScreen(
            walletDetailsCubit: wallet,
            args: const TokenInfoArgs(),
          ),
        ),
        GoRoute(
          path: '/bridge',
          builder: (_, state) {
            bridgePushes.add(state.uri.path);
            return const Scaffold(body: Text('bridge placeholder'));
          },
        ),
      ],
    );
    return MultiBlocProvider(
      providers: [BlocProvider<BridgeGateCubit>.value(value: gate)],
      child: MaterialApp.router(
        theme: ThemeData(extensions: [colors ?? GWColors.dark()]),
        routerConfig: router,
      ),
    );
  }
}

void _size(WidgetTester tester) {
  tester.view.physicalSize = const Size(2000, 1800);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('the earning wallet opens the bridge on the GNUS coin', (
    tester,
  ) async {
    _size(tester);
    final host = _Host(_appState());
    addTearDown(host.dispose);

    await tester.pumpWidget(host.build());
    await tester.pump();

    expect(find.text('Only the earning wallet can bridge.'), findsNothing);
    await tester.tap(find.text('Bridge'));
    await tester.pumpAndSettle();

    expect(host.bridgePushes, ['/bridge']);
    expect(host.wallet.state.selectedCoin, _gnus);
  });

  testWidgets('another account earning disables Bridge and says why', (
    tester,
  ) async {
    _size(tester);
    final host = _Host(_appState(linkedWallet: _otherAddress));
    addTearDown(host.dispose);

    await tester.pumpWidget(host.build());
    await tester.pump();

    expect(find.text('Only the earning wallet can bridge.'), findsOneWidget);
    await tester.tap(find.text('Bridge'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(host.bridgePushes, isEmpty);
  });

  testWidgets('a switch that began after the last frame stops the tap', (
    tester,
  ) async {
    _size(tester);
    final host = _Host(_appState());
    addTearDown(host.dispose);

    await tester.pumpWidget(host.build());
    await tester.pump();

    host.app = _appState(switching: _sdkAccount);
    await tester.tap(find.text('Bridge'));
    await tester.pumpAndSettle();

    expect(host.bridgePushes, isEmpty);
  });

  testWidgets('a disabled Bridge exposes its state and reason to semantics', (
    tester,
  ) async {
    _size(tester);
    final handle = tester.ensureSemantics();
    final host = _Host(_appState(linkedWallet: _otherAddress));
    addTearDown(host.dispose);

    await tester.pumpWidget(host.build());
    await tester.pump();

    final data = tester
        .getSemantics(find.bySemanticsLabel('Bridge'))
        .getSemanticsData();
    expect(data.hint, 'Only the earning wallet can bridge.');
    expect(data.flagsCollection.isButton, isTrue);
    expect(data.flagsCollection.isEnabled, ui.Tristate.isFalse);
    expect(
      find.bySemanticsLabel('Only the earning wallet can bridge.'),
      findsOneWidget,
    );
    handle.dispose();
  });
}
