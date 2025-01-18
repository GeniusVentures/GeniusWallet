import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/token.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/services/coins_service.dart';

class GnusState {
  final Coin? coin;
  final Token? tokenInfo;
  final bool isLoading;
  final String? errorMessage;

  const GnusState({
    this.coin,
    this.tokenInfo,
    this.isLoading = false,
    this.errorMessage,
  });

  GnusState copyWith({
    Coin? coin,
    Token? tokenInfo,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GnusState(
      coin: coin ?? this.coin,
      tokenInfo: tokenInfo ?? this.tokenInfo,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class GnusCubit extends Cubit<GnusState> {
  final CoinService coinService;
  final WalletDetailsCubit walletDetailsCubit;

  GnusCubit(this.coinService, this.walletDetailsCubit)
      : super(const GnusState());

  Future<Coin?> fetchGnusBalance() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final network = walletDetailsCubit.state.selectedNetwork;
    final walletAddress = walletDetailsCubit.state.selectedWallet?.address;

    if (network == null || walletAddress == null) {
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Invalid network or wallet address'));
      return null;
    }

    try {
      final coin = await coinService.fetchGnusBalance(walletAddress, network);
      emit(state.copyWith(isLoading: false, coin: coin));
      return coin;
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      return null;
    }
  }

  Future<Token?> fetchGnusInfo() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final network = walletDetailsCubit.state.selectedNetwork;

    if (network == null) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Invalid network'));
      return null;
    }

    try {
      final tokenInfo = await coinService.fetchGnusInfo(network);
      emit(state.copyWith(isLoading: false, tokenInfo: tokenInfo));
      return tokenInfo;
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      return null;
    }
  }
}
