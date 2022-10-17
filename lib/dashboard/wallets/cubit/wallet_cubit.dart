import 'dart:async';

import 'package:clipboard/clipboard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';

part 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  GeniusApi geniusApi;
  WalletCubit({
    WalletState initialState = const WalletState(),
    required this.geniusApi,
  }) : super(initialState);

  void selectWallet(Wallet wallet) {
    emit(state.copyWith(selectedWallet: wallet));
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
}
