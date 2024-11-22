import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/markets/bloc/markets_state.dart';

class MarketsCubit extends Cubit<MarketsState> {
  GeniusApi api;
  MarketsCubit({
    required this.api,
  }) : super(MarketsState());

  Future<void> loadMarkets() async {
    emit(state.copyWith(marketLoadingStatus: MarketsStatus.loading));

    try {
      final markets = await api.getMarkets();

      emit(state.copyWith(
        markets: markets,
        marketLoadingStatus: MarketsStatus.loaded,
      ));
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(marketLoadingStatus: MarketsStatus.error));
      }
    }
  }
}
