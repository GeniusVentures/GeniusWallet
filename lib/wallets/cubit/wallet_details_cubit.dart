import 'dart:async';

import 'package:clipboard/clipboard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/app/assets/read_asset.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';

part 'wallet_details_state.dart';

class WalletDetailsCubit extends Cubit<WalletDetailsState> {
  GeniusApi geniusApi;
  NetworkTokensProvider networkTokensProvider;
  WalletDetailsCubit(
      {WalletDetailsState initialState = const WalletDetailsState(),
      required this.geniusApi,
      required this.networkTokensProvider})
      : super(initialState);

  void selectNetwork(Network network) {
    emit(state.copyWith(selectedNetwork: network));
    // fetch coins if selecting a network
    getCoins();
  }

  void selectCoin(Coin coin) {
    emit(state.copyWith(selectedCoin: coin));
  }

  void selectWallet(Wallet wallet) {
    emit(state.copyWith(selectedWallet: wallet));
    // fetch coins after selecting a wallet
    getCoins();
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
      emit(state.copyWith(
        gasFeesStatus: WalletStatus.successful,
        gasFees: gasFee,
      ));
    } catch (e) {
      emit(state.copyWith(gasFeesStatus: WalletStatus.error));
    }
  }

  FutureOr<void> getCoins() async {
    try {
      emit(state.copyWith(coinsStatus: WalletStatus.loading));
      if (state.selectedWallet == null || state.selectedNetwork == null) {
        emit(state.copyWith(coinsStatus: WalletStatus.error));
        return;
      }
      final walletAddress = state.selectedWallet?.address;
      final rpcUrl = state.selectedNetwork?.rpcUrl;
      final networkSymbol = state.selectedNetwork?.symbol;

      if (walletAddress == null || rpcUrl == null || networkSymbol == null) {
        return;
      }

      // TODO:
      // IF SUPERGENIUS NETWORK... call the SDK to retrieve balances, etc.
      // WE SHOULD NOT CALL THE RPC STUFF
      // WE SHOULD CALL BALANCEOF and pass in the tokenIds from tokens.json
      // TODO: move this to the provider in main for performance
      readTokenAssets(
              walletAddress: walletAddress,
              network: state.selectedNetwork!,
              networkTokensProvider: networkTokensProvider)
          .then((List<Coin> coinList) {
        if (!isClosed) {
          emit(state.copyWith(
              coinsStatus: WalletStatus.successful,
              coins: coinList,
              // update selected coin to updated values after retrieval
              selectedCoin: state.selectedCoin != null
                  ? coinList.firstWhere(
                      (coin) => coin.address == state.selectedCoin?.address,
                      orElse: () =>
                          state.selectedCoin!, // Keep the old coin if not found
                    )
                  : null));
        }
      });
    } catch (e) {
      emit(state.copyWith(coinsStatus: WalletStatus.error));
    }
  }
}
