import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_gate_cubit.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_screen.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

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

class _RecordingApi implements GeniusApi {
  int burns = 0;
  final signers = <String>[];

  @override
  Future<ApiResponse<String>> getBrigeOutGasCost({
    required String contractAddress,
    required String rpcUrl,
    required String address,
    required String amountToBurn,
    required int sourceChainId,
    required int destinationChainId,
  }) async => ApiResponse.success('0.001 MATIC');

  @override
  Future<ApiResponse<String>> bridgeOut({
    required String contractAddress,
    required String rpcUrl,
    required String address,
    required String amountToBurn,
    required int sourceChainId,
    required int destinationChainId,
    bool shouldMintTokens = false,
  }) async {
    burns++;
    signers.add(address);
    return ApiResponse.error('rejected by the fake');
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _PushableWalletDetails extends WalletDetailsCubit {
  _PushableWalletDetails({
    required super.initialState,
    required super.geniusApi,
    required super.networkTokensProvider,
  });

  void push(WalletDetailsState next) => emit(next);
}

class _Host {
  _Host(this.app, {this.withGate = true}) {
    wallet = _PushableWalletDetails(
      initialState: const WalletDetailsState(
        selectedWallet: _wallet,
        selectedNetwork: _amoy,
        selectedCoin: _gnus,
        coins: [_gnus],
        coinsNetwork: _amoy,
        coinsStatus: WalletStatus.successful,
      ),
      geniusApi: api,
      networkTokensProvider: NetworkTokensProvider(),
    );
    gate = BridgeGateCubit(
      readAppState: () => app,
      appStates: appStream.stream,
      walletDetails: wallet,
    );
  }

  AppState app;
  final bool withGate;
  final api = _RecordingApi();
  final appStream = StreamController<AppState>.broadcast();
  late final _PushableWalletDetails wallet;
  late final BridgeGateCubit gate;

  Future<void> dispose() async {
    await gate.close();
    await wallet.close();
    await appStream.close();
  }

  Widget build() => MultiRepositoryProvider(
    providers: [RepositoryProvider<GeniusApi>.value(value: api)],
    child: MultiBlocProvider(
      providers: [
        BlocProvider<WalletDetailsCubit>.value(value: wallet),
        if (withGate) BlocProvider<BridgeGateCubit>.value(value: gate),
      ],
      child: MaterialApp(
        theme: ThemeData(extensions: [GWColors.dark()]),
        home: const BridgeScreen(fromToken: _gnus),
      ),
    ),
  );
}

Finder get _cta => find.widgetWithText(GWButton, 'Bridge');

Future<void> _readyCta(WidgetTester tester, _Host host) async {
  tester.view.physicalSize = const Size(1400, 2400);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(host.dispose);
  await tester.pumpWidget(host.build());
  await tester.pump();
  await tester.enterText(find.byType(TextField).first, '1');
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
  expect(_cta, findsOneWidget);
}

Future<void> _tap(WidgetTester tester) async {
  await tester.tap(_cta);
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _drainToasts(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 10));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the earning wallet submits the burn once', (tester) async {
    final host = _Host(_appState());
    await _readyCta(tester, host);

    await _tap(tester);

    expect(host.api.burns, 1);
    expect(find.text("Can't bridge"), findsNothing);
    await _drainToasts(tester);
  });

  testWidgets('an earning switch after the CTA is ready stops the burn', (
    tester,
  ) async {
    final host = _Host(_appState());
    await _readyCta(tester, host);

    host.app = _appState(linkedWallet: _otherAddress);
    await _tap(tester);

    expect(host.api.burns, 0);
    expect(find.text("Can't bridge"), findsOneWidget);
    expect(find.text('Only the earning wallet can bridge.'), findsOneWidget);
    expect(find.text('Bridging…'), findsNothing);
    await _drainToasts(tester);
  });

  testWidgets('a wallet switch while the screen is open stops the burn', (
    tester,
  ) async {
    final host = _Host(_appState());
    await _readyCta(tester, host);

    host.app = _appState(linkedWallet: _otherAddress);
    host.wallet.push(
      host.wallet.state.copyWith(
        selectedWallet: const Wallet(
          coinType: TWCoinType.TWCoinTypeEthereum,
          walletName: 'Other Wallet',
          currencySymbol: 'MATIC',
          walletType: WalletType.mnemonic,
          balance: 0,
          address: _otherAddress,
        ),
      ),
    );
    await _tap(tester);

    expect(host.api.burns, 0);
    expect(
      find.text('The wallet or network changed. Reopen Bridge.'),
      findsOneWidget,
    );
    await _drainToasts(tester);
  });

  testWidgets('a network switch to the same GNUS contract stops the burn', (
    tester,
  ) async {
    final host = _Host(_appState());
    await _readyCta(tester, host);

    const other = Network(
      name: 'BNB Chain',
      symbol: 'bnb',
      chainId: 56,
      rpcUrl: 'https://rpc.bnb.invalid',
    );
    host.wallet.push(
      host.wallet.state.copyWith(selectedNetwork: other, coinsNetwork: other),
    );
    await _tap(tester);

    expect(host.api.burns, 0);
    expect(
      find.text('The wallet or network changed. Reopen Bridge.'),
      findsOneWidget,
    );
    await _drainToasts(tester);
  });

  testWidgets('without a gate cubit the submit is refused', (tester) async {
    final host = _Host(_appState(), withGate: false);
    await _readyCta(tester, host);

    await _tap(tester);

    expect(host.api.burns, 0);
    expect(find.text("Can't bridge"), findsOneWidget);
    expect(find.text('Checking your GNUS balance.'), findsOneWidget);
    await _drainToasts(tester);
  });

  testWidgets('a gate coin other than the one being burned stops the burn', (
    tester,
  ) async {
    final host = _Host(_appState());
    await _readyCta(tester, host);

    host.wallet.push(
      host.wallet.state.copyWith(
        coins: const [Coin(symbol: 'GNUS', address: '0xdef', balance: 10)],
      ),
    );
    await _tap(tester);

    expect(host.api.burns, 0);
    expect(find.text("Can't bridge"), findsOneWidget);
    expect(
      find.text('The wallet or network changed. Reopen Bridge.'),
      findsOneWidget,
    );
    await _drainToasts(tester);
  });

  testWidgets('the same contract in another case still burns', (tester) async {
    final host = _Host(_appState());
    await _readyCta(tester, host);

    host.wallet.push(
      host.wallet.state.copyWith(
        coins: const [Coin(symbol: 'GNUS', address: '0xABC', balance: 10)],
      ),
    );
    await _tap(tester);

    expect(host.api.burns, 1);
    await _drainToasts(tester);
  });
}
