import 'dart:async';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/assets/read_asset.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';

part 'wallet_details_state.dart';

class WalletDetailsCubit extends Cubit<WalletDetailsState> {
  GeniusApi geniusApi;
  NetworkTokensProvider networkTokensProvider;

  // DEV-ONLY: dev switch flipped by DevMockHoldings-driven bubble buttons
  // (kDebugMode && kShowDevTools call sites only). Contains no fixtures
  // itself — fixtures stay in lib/dev/dev_mock_holdings.dart.
  bool mockMode = false;

  WalletDetailsCubit({
    WalletDetailsState initialState = const WalletDetailsState(),
    required this.geniusApi,
    required this.networkTokensProvider,
  }) : super(initialState);

  /// DEV-ONLY: injects offline mock holdings, short-circuiting the live
  /// read until [clearMock] is called.
  void injectMockCoins(List<Coin> coins, {required String balance}) {
    mockMode = true;
    emit(
      state.copyWith(
        coinsStatus: WalletStatus.successful,
        coins: coins,
        selectedWalletBalance: balance,
      ),
    );
  }

  /// DEV-ONLY: turns mock-mode off and resumes the real (live) data path.
  void clearMock() {
    mockMode = false;
    emit(
      state.copyWith(
        coinsStatus: WalletStatus.successful,
        coins: const [],
        selectedWalletBalance: '0',
      ),
    );
    getCoins();
  }

  Future<void> loadInitial({
    required Wallet selectedWallet,
    required Network selectedNetwork,
  }) async {
    emit(state.copyWith(initStatus: WalletStatus.loading));

    final balance = selectedWallet.balance.toString();

    emit(
      WalletDetailsState(
        selectedWallet: selectedWallet,
        selectedWalletBalance: balance,
        selectedNetwork: selectedNetwork,
      ),
    );

    emit(state.copyWith(initStatus: WalletStatus.successful));
  }

  void selectNetwork(Network network) {
    emit(state.copyWith(selectedNetwork: network));
    getCoins();
  }

  void selectCoin(Coin coin) {
    emit(state.copyWith(selectedCoin: coin));
  }

  void selectWallet(Wallet wallet) {
    emit(state.copyWith(selectedWallet: wallet));
    getCoins();
  }

  void setSelectedWalletBalance(String balance) {
    if (balance != state.selectedWalletBalance) {
      emit(state.copyWith(selectedWalletBalance: balance));
    }
  }

  /// Method that clears the state of `copyAddressStatus` once
  /// the Snackbar has been shown to the user.
  void messageShowed() {
    emit(state.copyWith(copyAddressStatus: WalletStatus.initial));
  }

  FutureOr<void> copyWalletAddress() async {
    try {
      emit(state.copyWith(copyAddressStatus: WalletStatus.loading));
      await FlutterClipboard.copy(state.selectedWallet!.address);
      emit(state.copyWith(copyAddressStatus: WalletStatus.successful));
    } catch (e) {
      emit(state.copyWith(copyAddressStatus: WalletStatus.error));
    }
  }

  FutureOr<void> getCurrentFees() async {
    try {
      emit(state.copyWith(gasFeesStatus: WalletStatus.loading));
      final gasFee = await geniusApi.getGasFees();
      emit(
        state.copyWith(gasFeesStatus: WalletStatus.successful, gasFees: gasFee),
      );
    } catch (e) {
      emit(state.copyWith(gasFeesStatus: WalletStatus.error));
    }
  }

  FutureOr<void> getCoins() async {
    // DEV-ONLY: while mock-mode is ON, the live read (and the
    // selectNetwork/selectWallet re-fetches that call this) must not
    // overwrite the injected mock holdings.
    if (mockMode) return;
    try {
      emit(state.copyWith(coinsStatus: WalletStatus.loading));
      if (state.selectedWallet == null || state.selectedNetwork == null) {
        emit(state.copyWith(coinsStatus: WalletStatus.error));
        return;
      }
      final walletAddress = state.selectedWallet?.address;
      final selectedNetwork = state.selectedNetwork!;

      if (walletAddress == null) {
        debugPrint("Can't get coin info: wallet address is null");
        return;
      }

      // Use native SDK for Super Genius wallets, or if the selected network
      // is a Super Genius network; otherwise use RPC.
      final isSgnusWallet =
          state.selectedWallet?.walletType == WalletType.sgnus;

      final Future<List<Coin>> coinFuture;
      if (isSgnusWallet || isSuperGeniusNetwork(selectedNetwork)) {
        coinFuture = readSuperGeniusTokenAssets(
          walletAddress: walletAddress,
          network: selectedNetwork,
          networkTokensProvider: networkTokensProvider,
          geniusApi: geniusApi,
        );
      } else {
        final rpcUrl = selectedNetwork.rpcUrl;
        final networkSymbol = selectedNetwork.symbol;
        if (rpcUrl == null || rpcUrl.isEmpty || networkSymbol == null) {
          debugPrint("Can't get coin info: no RPC URL or network symbol");
          return;
        }
        coinFuture = readTokenAssets(
          walletAddress: walletAddress,
          network: selectedNetwork,
          networkTokensProvider: networkTokensProvider,
        );
      }

      coinFuture.then((List<Coin> coinList) {
        if (!isClosed) {
          emit(
            state.copyWith(
              coinsStatus: WalletStatus.successful,
              coins: coinList,
              // update selected coin to updated values after retrieval
              selectedCoin: state.selectedCoin != null
                  ? coinList.firstWhere(
                      (coin) => coin.address == state.selectedCoin?.address,
                      orElse: () =>
                          state.selectedCoin!, // Keep the old coin if not found
                    )
                  : null,
            ),
          );
        }
      });
    } catch (e) {
      emit(state.copyWith(coinsStatus: WalletStatus.error));
    }
  }
}
