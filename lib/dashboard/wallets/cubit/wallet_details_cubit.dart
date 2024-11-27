import 'dart:async';

import 'package:clipboard/clipboard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/assets/read_asset.dart';
import 'package:genius_api/types/network_symbol.dart';

part 'wallet_details_state.dart';

class WalletDetailsCubit extends Cubit<WalletDetailsState> {
  GeniusApi geniusApi;
  WalletDetailsCubit({
    WalletDetailsState initialState = const WalletDetailsState(),
    required this.geniusApi,
  }) : super(initialState);

  void selectNetwork(Network network) {
    emit(state.copyWith(selectedNetwork: network));
    // fetch coins if selecting a network
    getCoins();
    // fetch new balance if selecting a network
    getWalletBalance();
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

  FutureOr<void> getNetworks() async {
    try {
      emit(state.copyWith(fetchNetworksStatus: WalletStatus.loading));
      if (state.selectedWallet == null) {
        emit(state.copyWith(fetchNetworksStatus: WalletStatus.error));
        return;
      }

      readNetworkAssets().then((List<Network> networks) {
        final network = networks.where((element) =>
            (element.symbol as NetworkSymbol).name ==
            state.selectedWallet?.currencySymbol);
        final Network selectedNetwork =
            network.isNotEmpty ? network.first : networks.first;
        emit(state.copyWith(
            fetchNetworksStatus: WalletStatus.successful,
            selectedNetwork: selectedNetwork,
            networks: networks));
      });
    } catch (e) {
      emit(state.copyWith(fetchNetworksStatus: WalletStatus.error));
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

      readTokenAssets(
              walletAddress: walletAddress,
              rpcUrl: rpcUrl,
              networkSymbol: networkSymbol)
          .then((List<Coin> coinList) {
        if (!isClosed) {
          emit(state.copyWith(
              coinsStatus: WalletStatus.successful, coins: coinList));
        }
      });
    } catch (e) {
      emit(state.copyWith(coinsStatus: WalletStatus.error));
    }
  }

  FutureOr<void> getWalletBalance() async {
    try {
      emit(state.copyWith(balanceStatus: WalletStatus.loading));
      if (state.selectedWallet == null || state.selectedNetwork == null) {
        emit(state.copyWith(balanceStatus: WalletStatus.error));
        return;
      }
      final balance = await geniusApi.getWalletBalance(
          state.selectedNetwork?.rpcUrl ?? "",
          state.selectedWallet?.address ?? "");
      emit(state.copyWith(
          balance: balance, balanceStatus: WalletStatus.successful));
    } catch (e) {
      emit(state.copyWith(balanceStatus: WalletStatus.error));
    }
  }
}
